# == Class: puppet::conf::r10k
#
# Creates the default global r10k configuration directory and file:
#
#   /etc/puppetlabs/r10k/r10k.yaml
#
# === Parameters
#
# [*group*]
#  The group for the global r10k configuration file and directory resources,
#  defaults is platform's superuser group ('root' on Linux, 'wheel' on UNIX).
#
# [*mode*]
#  The mode for the global r10k configuration file and directory resources,
#  defaults to '0644'.
#
# [*settings*]
#  TODO
#
class puppet::conf::r10k(
  $group    = $puppet::params::root_group,
  $mode     = '0644',
  $settings = {},
) inherits puppet::params {
  validate_hash($settings)

  include puppet::conf::puppetlabs

  file { $puppet::params::r10k_confdir:
    ensure  => directory,
    owner   => 'root',
    group   => $group,
    mode    => $mode,
    require => Class['puppet::conf::puppetlabs'],
  }

  create_resources('puppet::r10k::config',
    {
      "${puppet::params::r10k_config_file}" => $settings
    }
  )
}
