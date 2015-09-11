# == Class: puppet::config::dir
#
# Creates the configuration directory for Puppet.
#
class puppet::config::dir(
  $group = $puppet::params::root_group,
  $mode  = '0644',
) inherits puppet::params {
  include puppet::config::puppetlabs

  file { $puppet::params::confdir:
    ensure  => directory,
    owner   => 'root',
    group   => $group,
    mode    => $mode,
    require => Class['puppet::config::puppetlabs'],
  }
}
