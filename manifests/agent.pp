# == Class: puppet::agent
#
# Installs Puppet and an agent configuration file (puppet.conf).
#
# === Parameters
#
# [*server*]
#   The hostname of the Puppet master.  Defaults to "puppet.${domain}".
#
# [*pluginsync*]
#   Whether or not to enable `pluginsync` in the configuration file.
#   Defaults to true.
#
# [*report*]
#   Whether to enable reports; default is true.
#
class puppet::agent(
  $server     = "puppet.${::domain}",
  $pluginsync = true,
  $report     = true,
) inherits puppet::params {
  include puppet
  include puppet::config

  puppet_setting { 'agent/pluginsync':
    value => $pluginsync,
  }

  puppet_setting { 'agent/report':
    value => $report,
  }

  if $server {
    puppet_setting { 'agent/server':
      value => $server,
    }
  }

  anchor { 'puppet::agent::end':
    require => Class['puppet', 'puppet::config'],
  }
}
