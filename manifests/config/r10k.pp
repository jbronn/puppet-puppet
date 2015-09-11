# == Class: puppet::config::r10k
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
#  A hash of settings to pass to the `puppet::r10k::config` defined type,
#  (to pupulate the actual settings in r10k.yaml), defaults to {}.
#
class puppet::config::r10k(
  $group    = $puppet::params::root_group,
  $mode     = '0644',
  $settings = {},
) inherits puppet::params {
  validate_hash($settings)

  include puppet::config::puppetlabs

  file { $puppet::params::r10k_confdir:
    ensure  => directory,
    owner   => 'root',
    group   => $group,
    mode    => $mode,
    require => Class['puppet::config::puppetlabs'],
  }

  $config_settings = merge($settings,
    {
      'group' => $group,
      'mode'  => $mode,
    }
  )

  create_resources('puppet::r10k::config',
    {
      "${puppet::params::r10k_config_file}" => $config_settings,
    }
  )
}
