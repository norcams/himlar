require 'json'

Facter.add('ceph_osds') do
  confine hostname: /storage|object-ceph/

  output = Facter::Core::Execution.execute('ceph osd tree -f json',
                                           timeout: 30)
  osds = []
  parsed_output = JSON.parse(output)['nodes']
  parsed_output.each do |node|
    next unless node['name'] == Facter.value(:hostname)
    node['children'].each do |osd|
      osds << osd
    end
  end
  setcode do
    osds
  end
end
