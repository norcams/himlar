def get_uptime():
    with open('/proc/uptime', 'r') as f:
        uptime_seconds = float(f.readline().split()[0])
        uptime = uptime_seconds / 60 / 60 / 24
    return int(round(uptime))

def get_ipaddress():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    ip_address = s.getsockname()[0]
    s.close()
    return ip_address

def checksum_file(file_path):
    with open(file_path, 'rb') as f:
        data = f.read()
        checksum = hashlib.md5(data).hexdigest()
    return checksum

