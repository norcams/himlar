Facter.add('intel_x710') do
  confine kernel: 'Linux'

  output = Facter::Core::Execution.execute('which lspci && lspci 2>/dev/null',
                                           timeout: 30)
  slot_numbers = []
  devices = output.split("\n").select { |e| e[/X710/] }
  unless devices.empty?
    devices.each do |s|
      slot_numbers << s.split("\s")[0]
    end
  end
  setcode do
    slot_numbers
  end
end
