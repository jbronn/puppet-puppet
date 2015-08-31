# == Class: puppet::conf::file
#
# Creates the configuration file for Puppet itself.
#
class puppet::conf::file(
  $group = $puppet::params::root_group,
  $mode  = '0644',
) inherits puppet::params {
  include puppet::conf::dir

  # Ensure the puppet configuration file exists, but don't manage
  # its content
  file { $puppet::params::config_file:
    ensure  => file,
    owner   => 'root',
    group   => $group,
    mode    => $mode,
    require => Class['puppet::conf::dir'],
  }

  if versioncmp($::puppetversion, '4.0.0') < 0 {
    # If on Puppet 3.x, ensure we have default configuration file
    # pointing to the 4.x compatible location.
    file { '/etc/puppet':
      ensure => directory,
      owner  => 'root',
      group  => $puppet::conf::dir::group,
      mode   => $puppet::conf::dir::_mode,
    }

    file { '/etc/puppet/puppet.conf':
      ensure  => link,
      target  => $puppet::params::config_file,
      require => File[$puppet::params::config_file],
    }
  }

  # Ensure configuration directory / file scaffolding is in place
  # prior to using the `puppet_setting` type.
  Class['puppet::conf::file'] -> Puppet_setting<| |>
}
