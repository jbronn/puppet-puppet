Puppet::Type.newtype(:puppet_setting) do
  ensurable

  newparam(:name, :namevar => true) do
    desc 'section/setting to manage in puppet.conf'
    # namevar should be of the form section/setting
    newvalues(/^(agent|main|master|user)\/\S+$/)
  end

  newproperty(:value) do
    desc 'The value of the puppet configuration setting.'
    munge do |v|
      v.to_s.strip
    end
  end

end
