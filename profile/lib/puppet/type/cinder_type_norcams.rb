Puppet::Type.newtype(:cinder_type_norcams) do

  desc 'Type for managing cinder types with extra params.'

  ensurable

  newparam(:name, :namevar => true) do
    newvalues(/\S+/)
  end

  newparam(:visibility) do
    desc 'Whether the volume type is public or private. Defaults to public.'
    newvalues(/(p|P)ublic/, /(p|P)rivate/, public, private )
  end

  newproperty(:properties, :array_matching => :all) do
    desc 'The properties of the cinder type. Should be an array, all items should match pattern <key=value1[,value2 ...]>'
    defaultto []
    def insync?(is)
      return false unless is.is_a? Array
      is.sort == should.sort
    end
    validate do |value|
      raise ArgumentError, "Properties doesn't match" unless value.match(/^\s*[^=\s]+=[^=\s]+$/)
    end
  end

  autorequire(:anchor) do
    ['cinder::service::end']
  end
end
