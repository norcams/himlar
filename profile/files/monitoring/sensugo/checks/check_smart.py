#!/usr/bin/python3
"""Sensu Go check for disk health, based on smartctl(8).

Managed by Puppet (profile::monitoring::smart) - do not edit on the node.

Devices are auto detected with 'smartctl --scan-open' unless one or more
--device options are given. Every device is then inspected with
'smartctl --all' and the JSON output is evaluated against the thresholds
below. The check exits with the worst status found, using the usual
Nagios/Sensu convention: 0 OK, 1 WARNING, 2 CRITICAL, 3 UNKNOWN.

Needs root, so it is normally run as 'sudo /usr/local/bin/check_smart.py'.
"""

import argparse
import fnmatch
import json
import subprocess
import sys

OK = 0
WARNING = 1
CRITICAL = 2
UNKNOWN = 3

STATUS_TEXT = {OK: 'OK', WARNING: 'WARNING', CRITICAL: 'CRITICAL', UNKNOWN: 'UNKNOWN'}

# How bad a status is when we aggregate. A real CRITICAL beats an UNKNOWN.
STATUS_RANK = {OK: 0, WARNING: 1, UNKNOWN: 2, CRITICAL: 3}

# smartctl(8) exit status bits
BIT_CMDLINE = 1 << 0       # command line did not parse
BIT_OPEN = 1 << 1          # device open failed
BIT_CMD_FAILED = 1 << 2    # some SMART or other ATA command failed
BIT_DISK_FAILING = 1 << 3  # SMART status check returned "DISK FAILING"
BIT_PREFAIL_NOW = 1 << 4   # prefail attribute below threshold
BIT_PREFAIL_PAST = 1 << 5  # attribute was below threshold in the past
BIT_ERROR_LOG = 1 << 6     # device error log contains errors
BIT_SELFTEST_LOG = 1 << 7  # self-test log contains errors

# ATA attributes checked by raw value: id, option prefix, description,
# default warning, default critical. A negative threshold disables it.
ATTRIBUTE_CHECKS = (
    (5, 'reallocated', 'reallocated sectors', 1, 100),
    (187, 'reported', 'reported uncorrectable errors', 1, 10),
    (197, 'pending', 'current pending sectors', 1, 10),
    (198, 'offline', 'offline uncorrectable sectors', 1, 10),
    (199, 'crc', 'interface CRC errors', 10, -1),
)

# Top level keys that tell us smartctl got SMART data out of the device.
# smartmontools 7.x has no JSON field for "SMART support is: Unavailable",
# so this is how we recognize USB bridges, RAID volumes, SD cards and the like.
SMART_DATA_KEYS = (
    'smart_status',
    'ata_smart_data',
    'ata_smart_attributes',
    'nvme_smart_health_information_log',
    'scsi_error_counter_log',
    'scsi_grown_defect_list',
)

# ATA attributes where the normalized value is "percent of life left". Only
# used when the attribute name confirms it, since these ids are reused for
# other purposes by some vendors (231 is Temperature_Celsius on a few SSDs).
WEAR_ATTRIBUTE_IDS = (177, 202, 231, 233)
WEAR_ATTRIBUTE_WORDS = ('wear', 'life', 'endurance', 'lifetime')


class SmartctlError(Exception):
    """smartctl could not be run, or did not return usable JSON."""


class DeviceStatus(object):
    """Collected result for a single device."""

    def __init__(self, name, devtype):
        self.name = name
        self.type = devtype
        self.status = OK
        self.problems = []
        self.perfdata = []
        self.model = None
        self.serial = None
        self.skipped = None

    def escalate(self, status, message):
        if STATUS_RANK[status] > STATUS_RANK[self.status]:
            self.status = status
        self.problems.append(message)

    def label(self):
        parts = [self.name]
        if self.type and self.type != self.name:
            parts.append('[%s]' % self.type)
        if self.model:
            parts.append(self.model)
        if self.serial:
            parts.append('s/n %s' % self.serial)
        return ' '.join(parts)

    def line(self):
        if self.skipped:
            detail = 'skipped: %s' % self.skipped
        elif self.problems:
            detail = ', '.join(self.problems)
        else:
            detail = 'healthy'
        return '%s %s: %s' % (STATUS_TEXT[self.status], self.label(), detail)


def run_smartctl(binary, args, timeout):
    """Run smartctl with JSON output. Returns (exit status, parsed json)."""
    cmd = [binary, '--json=c'] + args
    try:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            stdout, stderr = proc.communicate(timeout=timeout)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.communicate()
            raise SmartctlError('timed out after %ds: %s' % (timeout, ' '.join(cmd)))
    except OSError as exc:
        raise SmartctlError('could not run %s: %s' % (binary, exc))

    output = stdout.decode('utf-8', 'replace')
    try:
        data = json.loads(output)
    except ValueError:
        detail = stderr.decode('utf-8', 'replace').strip() or output.strip()
        raise SmartctlError('no JSON from "%s" (smartmontools >= 7.0 required): %s'
                            % (' '.join(cmd), detail[:200]))
    return proc.returncode, data


def smartctl_messages(data):
    """Join the messages smartctl reports about a device."""
    messages = (data.get('smartctl') or {}).get('messages') or []
    return '; '.join(m.get('string', '').strip() for m in messages if m.get('string'))


def scan_devices(opts):
    """Auto detect devices. Returns a list of (name, type) tuples."""
    _status, data = run_smartctl(opts.smartctl, ['--scan-open'], opts.timeout)
    devices = []
    for entry in data.get('devices') or []:
        name = entry.get('name')
        if name:
            devices.append((name, entry.get('type')))
    return devices


def parse_device_option(value):
    """Parse a --device value on the form PATH or PATH:TYPE."""
    if ':' in value:
        name, devtype = value.split(':', 1)
        return (name.strip(), devtype.strip())
    return (value.strip(), None)


def excluded(name, patterns):
    return any(fnmatch.fnmatch(name, pattern) for pattern in patterns)


def threshold_check(dev, value, warning, critical, description):
    """Escalate when value has reached the warning or critical threshold."""
    if not isinstance(value, int) or isinstance(value, bool):
        return
    if critical >= 0 and value >= critical:
        dev.escalate(CRITICAL, '%d %s' % (value, description))
    elif warning >= 0 and value >= warning:
        dev.escalate(WARNING, '%d %s' % (value, description))


def check_ata_attributes(opts, dev, data):
    """Evaluate the ATA attribute table. Returns the failed attribute names."""
    table = (data.get('ata_smart_attributes') or {}).get('table') or []
    if not table:
        return [], []
    by_id = {}
    failed_now = []
    failed_past = []
    for attr in table:
        by_id[attr.get('id')] = attr
        name = attr.get('name') or 'attribute %s' % attr.get('id')
        if attr.get('when_failed') == 'now':
            failed_now.append(name)
        elif attr.get('when_failed') == 'past':
            failed_past.append(name)

    if failed_now:
        dev.escalate(CRITICAL, 'attribute below threshold now: %s' % ', '.join(failed_now))
    if failed_past:
        dev.escalate(WARNING, 'attribute below threshold in the past: %s' % ', '.join(failed_past))

    for attr_id, prefix, description, _w, _c in ATTRIBUTE_CHECKS:
        attr = by_id.get(attr_id)
        if not attr:
            continue
        raw = (attr.get('raw') or {}).get('value')
        if not isinstance(raw, int):
            continue
        dev.perfdata.append(('%s_%s' % (dev.name, prefix), raw, None))
        threshold_check(dev, raw, getattr(opts, prefix + '_warning'),
                        getattr(opts, prefix + '_critical'), description)

    # Life used, derived from the normalized value of a vendor wear attribute
    for attr_id in WEAR_ATTRIBUTE_IDS:
        attr = by_id.get(attr_id)
        if not attr:
            continue
        name = (attr.get('name') or '').lower()
        if not any(word in name for word in WEAR_ATTRIBUTE_WORDS):
            continue
        remaining = attr.get('value')
        if not isinstance(remaining, int) or not 0 <= remaining <= 100:
            continue
        check_wear(opts, dev, 100 - remaining)
        break

    return failed_now, failed_past


def check_wear(opts, dev, used):
    dev.perfdata.append(('%s_life_used' % dev.name, used, '%'))
    threshold_check(dev, used, opts.wear_warning, opts.wear_critical, 'percent of write endurance used')


def check_nvme(opts, dev, data):
    log = data.get('nvme_smart_health_information_log')
    if not log:
        return

    warning_flags = log.get('critical_warning')
    if isinstance(warning_flags, int) and warning_flags != 0:
        dev.escalate(CRITICAL, 'NVMe critical warning flags 0x%02x' % warning_flags)

    spare = log.get('available_spare')
    spare_threshold = log.get('available_spare_threshold')
    if isinstance(spare, int) and isinstance(spare_threshold, int):
        dev.perfdata.append(('%s_available_spare' % dev.name, spare, '%'))
        if spare < spare_threshold:
            dev.escalate(CRITICAL, 'available spare %d%% is below the drive threshold %d%%'
                         % (spare, spare_threshold))

    used = log.get('percentage_used')
    if isinstance(used, int):
        check_wear(opts, dev, used)

    media_errors = log.get('media_errors')
    if isinstance(media_errors, int):
        dev.perfdata.append(('%s_media_errors' % dev.name, media_errors, None))
        threshold_check(dev, media_errors, opts.media_warning, opts.media_critical, 'media errors')


def check_scsi(opts, dev, data):
    defects = data.get('scsi_grown_defect_list')
    if isinstance(defects, int):
        dev.perfdata.append(('%s_grown_defects' % dev.name, defects, None))
        threshold_check(dev, defects, opts.defects_warning, opts.defects_critical,
                        'entries in the grown defect list')

    counters = data.get('scsi_error_counter_log') or {}
    uncorrected = 0
    seen = False
    for operation in ('read', 'write', 'verify'):
        errors = (counters.get(operation) or {}).get('total_uncorrected_errors')
        if isinstance(errors, int):
            uncorrected += errors
            seen = True
    if seen:
        dev.perfdata.append(('%s_uncorrected' % dev.name, uncorrected, None))
        threshold_check(dev, uncorrected, opts.media_warning, opts.media_critical,
                        'uncorrected errors')

    used = data.get('scsi_percentage_used_endurance_indicator')
    if isinstance(used, int):
        check_wear(opts, dev, used)


def check_temperature(opts, dev, data):
    current = (data.get('temperature') or {}).get('current')
    if not isinstance(current, int):
        return
    # no unit of measurement, 'C' is not one Nagios perfdata knows about
    dev.perfdata.append(('%s_temperature' % dev.name, current, None))
    threshold_check(dev, current, opts.temp_warning, opts.temp_critical, 'degrees Celsius')


def check_device(opts, name, devtype):
    dev = DeviceStatus(name, devtype)
    args = ['--all']
    if devtype:
        args += ['--device', devtype]
    args.append(name)

    try:
        exit_status, data = run_smartctl(opts.smartctl, args, opts.timeout)
    except SmartctlError as exc:
        dev.escalate(UNKNOWN, str(exc))
        return dev

    dev.model = data.get('model_name')
    dev.serial = data.get('serial_number')

    if exit_status & BIT_CMDLINE:
        dev.escalate(UNKNOWN, 'smartctl rejected the command line: %s'
                     % (smartctl_messages(data) or 'no details'))
        return dev
    if exit_status & BIT_OPEN:
        dev.escalate(UNKNOWN, 'could not open device: %s'
                     % (smartctl_messages(data) or 'no details'))
        return dev

    support = data.get('smart_support') or {}
    if support.get('available') is False or not any(key in data for key in SMART_DATA_KEYS):
        note = smartctl_messages(data)
        dev.skipped = 'no SMART data%s' % (': %s' % note if note else '')
        return dev

    if (data.get('smart_status') or {}).get('passed') is False or exit_status & BIT_DISK_FAILING:
        dev.escalate(CRITICAL, 'SMART health self-assessment FAILED')

    failed_now, failed_past = check_ata_attributes(opts, dev, data)

    if exit_status & BIT_PREFAIL_NOW and not failed_now:
        dev.escalate(CRITICAL, 'a pre-failure attribute is below its threshold')
    if exit_status & BIT_PREFAIL_PAST and not failed_past:
        dev.escalate(WARNING, 'a pre-failure attribute was below its threshold in the past')
    if exit_status & BIT_CMD_FAILED:
        # also set when SMART is supported but turned off on the device
        dev.escalate(WARNING, 'a SMART command failed, SMART may be disabled: %s'
                     % (smartctl_messages(data) or 'no details'))
    if exit_status & BIT_ERROR_LOG and not opts.ignore_error_log:
        dev.escalate(WARNING, 'the device error log contains errors')
    if exit_status & BIT_SELFTEST_LOG and not opts.ignore_selftest_log:
        dev.escalate(WARNING, 'the self-test log contains errors')

    check_nvme(opts, dev, data)
    check_scsi(opts, dev, data)
    check_temperature(opts, dev, data)

    return dev


def format_perfdata(devices):
    fields = []
    for dev in devices:
        for name, value, unit in dev.perfdata:
            label = name.replace('/dev/', '').replace('/', '_')
            fields.append('%s=%s%s' % (label, value, unit or ''))
    return ' '.join(fields)


def parse_args(argv):
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('-d', '--device', action='append', default=[], metavar='PATH[:TYPE]',
                        help='device to check, e.g. /dev/sda or /dev/bus/0:megaraid,3. '
                             'Repeatable. Disables auto detection.')
    parser.add_argument('-x', '--exclude', action='append', default=[], metavar='GLOB',
                        help='skip auto detected devices matching this glob. Repeatable.')
    parser.add_argument('-l', '--list-devices', action='store_true',
                        help='list the devices that would be checked, then exit')
    parser.add_argument('--smartctl', default='/usr/sbin/smartctl',
                        help='path to smartctl (default: %(default)s)')
    parser.add_argument('--timeout', type=int, default=30, metavar='SECONDS',
                        help='timeout per smartctl invocation (default: %(default)s)')
    parser.add_argument('--allow-no-devices', action='store_true',
                        help='exit OK instead of UNKNOWN when no devices are found')
    parser.add_argument('--ignore-error-log', action='store_true',
                        help='do not warn when the device error log is non-empty')
    parser.add_argument('--ignore-selftest-log', action='store_true',
                        help='do not warn when the self-test log holds failed tests')
    parser.add_argument('--perfdata', action='store_true',
                        help='append Nagios perfdata to the summary line')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='print one line per device, not only for the unhealthy ones')
    parser.add_argument('--temp-warning', type=int, default=55, metavar='C')
    parser.add_argument('--temp-critical', type=int, default=65, metavar='C')
    parser.add_argument('--wear-warning', type=int, default=85, metavar='PERCENT',
                        help='percent of write endurance used (default: %(default)s)')
    parser.add_argument('--wear-critical', type=int, default=95, metavar='PERCENT')
    parser.add_argument('--media-warning', type=int, default=1, metavar='COUNT',
                        help='NVMe media errors / SCSI uncorrected errors (default: %(default)s)')
    parser.add_argument('--media-critical', type=int, default=10, metavar='COUNT')
    parser.add_argument('--defects-warning', type=int, default=10, metavar='COUNT',
                        help='entries in the SCSI grown defect list (default: %(default)s)')
    parser.add_argument('--defects-critical', type=int, default=100, metavar='COUNT')
    for _id, prefix, description, warning, critical in ATTRIBUTE_CHECKS:
        parser.add_argument('--%s-warning' % prefix, type=int, default=warning, metavar='COUNT',
                            help='%s (default: %%(default)s)' % description)
        parser.add_argument('--%s-critical' % prefix, type=int, default=critical, metavar='COUNT')
    return parser.parse_args(argv)


def main(argv):
    opts = parse_args(argv)

    try:
        if opts.device:
            targets = [parse_device_option(value) for value in opts.device]
        else:
            targets = [(name, devtype) for name, devtype in scan_devices(opts)
                       if not excluded(name, opts.exclude)]
    except SmartctlError as exc:
        print('UNKNOWN - %s' % exc)
        return UNKNOWN

    if opts.list_devices:
        for name, devtype in targets:
            print('%s %s' % (name, devtype or ''))
        return OK

    if not targets:
        if opts.allow_no_devices:
            print('OK - no devices to check')
            return OK
        print('UNKNOWN - no devices found, check --device or --exclude')
        return UNKNOWN

    devices = [check_device(opts, name, devtype) for name, devtype in targets]

    counts = {OK: 0, WARNING: 0, CRITICAL: 0, UNKNOWN: 0}
    skipped = 0
    worst = OK
    for dev in devices:
        if dev.skipped:
            skipped += 1
        else:
            counts[dev.status] += 1
        if STATUS_RANK[dev.status] > STATUS_RANK[worst]:
            worst = dev.status

    parts = []
    for status in (CRITICAL, WARNING, UNKNOWN, OK):
        if counts[status]:
            parts.append('%d %s' % (counts[status], STATUS_TEXT[status].lower()))
    if skipped:
        parts.append('%d skipped' % skipped)
    summary = '%s - %s of %d device(s)' % (STATUS_TEXT[worst], ', '.join(parts), len(devices))
    if opts.perfdata:
        perfdata = format_perfdata(devices)
        if perfdata:
            summary = '%s | %s' % (summary, perfdata)
    print(summary)

    for dev in devices:
        if opts.verbose or dev.status != OK:
            print(dev.line())

    return worst


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
