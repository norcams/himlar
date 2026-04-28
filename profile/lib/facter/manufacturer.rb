Facter.add(:manufacturer) do
  has_weight 1000
  setcode do
    product = Facter.value(:productname)
    if product && product =~ /AS[- ]?2115GT-HNTR/i
      'Supermicro_atlas3'
    else
      Facter.value(:dmi_manufacturer) ||
      Facter.value(:bios_vendor) ||
      nil
    end
  end
end
