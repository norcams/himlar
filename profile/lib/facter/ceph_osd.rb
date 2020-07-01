require 'json'

def parse_output(output)
  osd_array = []
  parsed_output = JSON.parse(output)['nodes']
  parsed_output.each do |node|
    next unless node['name'] == Facter.value(:hostname)
    node['children'].each do |osd|
      osd_array << "ceph-osd.#{osd}"
    end
  end
  osd_array
end

Facter.add('ceph_osds') do
  confine hostname: /storage|object-ceph/

  setcode do
    if Facter::Core::Execution.which("ceph")
      output = Facter::Core::Execution.execute('ceph osd tree -f json 2>/dev/null',
                                                timeout: 30)
      osds = parse_output(output)
    else
      osds = []
    end
  osds
  end
end
