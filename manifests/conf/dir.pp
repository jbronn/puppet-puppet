# == Class: puppet::conf::dir
#
# Creates the configuration directory for Puppet.
#
class puppet::conf::dir(
  $group = $puppet::params::root_group,
  $mode  = '0644',
) inherits puppet::params {
  include puppet::conf::puppetlabs

  file { $puppet::params::confdir:
    ensure  => directory,
    owner   => 'root',
    group   => $group,
    mode    => $mode,
    require => Class['puppet::conf::puppetlabs'],
  }
}
