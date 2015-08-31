Puppet::Type.type(:puppet_setting).provide(
  :ini_setting,
  # set ini_setting as the parent provider
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  def section
    # implement section as the first part of the namevar
    resource[:name].split('/', 2).first
  end

  def setting
    # implement setting as the second part of the namevar
    resource[:name].split('/', 2).last
  end

  # The path to the (open source) puppet configuration file has to
  # be hard coded to allow resource purging.
  def self.file_path
    '/etc/puppetlabs/puppet/puppet.conf'
  end
end
