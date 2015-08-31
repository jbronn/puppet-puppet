# == Class: puppet::conf::puppetlabs
#
# Creates base configuration directory for all open source Puppet Labs software:
# '/etc/puppetlabs'.
#
class puppet::conf::puppetlabs(
  $group = $puppet::params::root_group,
  $mode  = '0644',
) inherits puppet::params {
  file { $puppet::params::puppetlabs:
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => $mode,
  }
}
