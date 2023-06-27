def lspci_match(regex)
  output = Facter::Core::Execution.execute("which lspci && lspci 2>/dev/null", timeout: 30)
  matches = output.scan(regex)
  matches.flatten.reject {|s| s.nil?}.length
end

Facter.add(:lspci_has, :type => :aggregate) do
  confine :kernel => "Linux"

  chunk(:intel82599sfp) do
    count = lspci_match(/Intel.*82599ES.*SFP\+/)
    { "intel82599sfp" => count > 0 }
  end

  chunk(:) do
    count = lspci_match(/Intel.*10G 2P X520.*/)
    { "x520sfp" => count > 0 }
  end

end
