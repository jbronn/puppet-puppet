# == Class: puppet::master
#
# Installs the Puppet Master, running behind Apache/Phusion Passenger.
#
# === Parameters
#
# [*certname*]
#  The name of the puppet master, defaults to the node's FQDN.
#
# [*user*]
#  The name of the user to run the Puppet master as.  Defaults to 'puppet'.
#
# [*uid*]
#  The uid to use for the Puppet user.  Defaults to '580'.
#
# [*group*]
#  The name of the group to run the Puppet master as.  Defaults to 'puppet'.
#
# [*gid*]
#  The gid to use for the Puppet group.  Defaults to '580'.
#
# [*confdir*]
#  The path of the configuration directory, defaults to '/etc/puppet'.
#
# [*confdir_mode*]
#  File mode for the configuration directory, defaults to '0640'.
#
# [*hiera_config*]
#  The Hiera configuration file path, defaults to '/etc/puppet/hiera.yaml'.
#
# [*hiera_datadir*]
#  The path to the Hiera data directory, defaults to '/etc/puppet/hiera'.
#
# [*hiera_datadir_mode*]
#  File mode for the Hiera data directory, defaults to '0640'.
#
# [*hiera_backends*]
#  Array of Hiera backends to use, defaults to ['yaml'].
#
# [*hiera_settings*]
#  The settings hash parameter passed through to the `puppet::hiera_config`
#  resource, the default just specifies the datadir for the YAML backend.
#
# [*hiera_hierarchy*]
#  The hierarchy used by Hiera, defaults to ["'%{::fqdn}'", 'common'].
#
# [*manifestdir*]
#  Path for manifests.  Defaults to '/etc/puppet/manifests'.
#
# [*manifestdir_mode*]
#  File mode for the manifests directory, defaults to '0640'.
#
# [*modulepath*]
#  Path for modules.  Defaults to '/etc/puppet/modules'.
#
# [*modulepath_mode*]
#  File mode for the modules directory, defaults to '0640'.
#
# [*ssldir*]
#  Where Puppet stores it's SSL certificates.  Defaults to '/etc/puppet/ssl'.
#
# [*vardir*]
#  One of Puppet's main working directories.  Defaults to '/var/lib/puppet'.
#
# [*logdir*]
#  Where the master should store its logs.  Defaults to '/var/log/puppet'.
#
# [*pluginsync*]
#  Whether or not to enable `pluginsync` in the configuration file.
#  Defaults to true.
#
# [*config*]
#  Advanced option to overide the hash used to create the master
#  `sys::inifile` resource for puppet.conf.
#
class puppet::master(
  $certname           = $puppet::params::certname,
  $user               = $puppet::params::user,
  $uid                = $puppet::params::uid,
  $group              = $puppet::params::group,
  $gid                = $puppet::params::gid,
  $confdir            = $puppet::params::confdir,
  $confdir_mode       = '0640',
  $hiera_config       = $puppet::params::hiera_config,
  $hiera_datadir      = $puppet::params::hiera_datadir,
  $hiera_datadir_mode = '0640',
  $hiera_backends     = $puppet::params::hiera_backends,
  $hiera_settings     = $puppet::params::hiera_settings,
  $hiera_hierarchy    = $puppet::params::hiera_hierarchy,
  $manifestdir        = $puppet::params::manifestdir,
  $manifestdir_mode   = '0640',
  $modulepath         = $puppet::params::modulepath,
  $modulepath_mode    = '0640',
  $module_repository  = $puppet::params::module_repository,
  $ssldir             = $puppet::params::ssldir,
  $vardir             = $puppet::params::vardir,
  $logdir             = $puppet::params::logdir,
  $pluginsync         = $puppet::params::pluginsync,
  $config             = undef,
) inherits puppet::params {

  # Puppet itself is required first.
  include puppet
  include puppet::master::apache
  $home = $vardir

  # Puppet user/group settings.
  group { $group:
    ensure  => present,
    gid     => $gid,
    require => Class['puppet'],
  }

  user { $user:
    ensure  => present,
    uid     => $uid,
    gid     => $gid,
    home    => $vardir,
    shell   => '/bin/false',
    require => Group[$group],
  }

  File {
    owner   => $user,
    group   => $group,
    require => User[$user]
  }

  ## Puppet directories ##
  file { $confdir:
    ensure  => directory,
    mode    => $confdir_mode,
  }

  file { $manifestdir:
    ensure  => directory,
    mode    => $manifestdir_mode,
  }

  file { $modulepath:
    ensure  => directory,
    mode    => $modulepath_mode,
  }

  file { $ssldir:
    ensure  => directory,
    # Puppet always changes mode to this, not going to fight it.
    mode    => '0661',
  }

  file { $vardir:
    ensure  => directory,
    mode    => '0640',
  }

  file { $logdir:
    ensure  => directory,
    mode    => '0640',
  }

  file { $hiera_datadir:
    ensure  => directory,
    mode    => $hiera_datadir_mode,
  }

  ## Puppet configuration files ##

  # Hiera configuration.
  puppet::hiera_config { $hiera_config:
    backends  => $hiera_backends,
    settings  => $hiera_settings,
    hierarchy => $hiera_hierarchy,
    owner     => $user,
    group     => $group,
    notify    => Service['apache'],
    require   => File[$hiera_datadir],
  }

  # Puppet configuration (puppet.conf).
  $config_file = "${confdir}/puppet.conf"

  # Using either a default or user-supplied hash for constructing the
  # Puppet configuration file with `sys::inifile`.
  if $config {
    $config_hash = $config
  } else {
    $config_hash = {
      'main' => {
        'certname'          => $certname,
        'confdir'           => $confdir,
        'hiera_config'      => $hiera_config,
        'logdir'            => $logdir,
        'manifestdir'       => $manifestdir,
        'modulepath'        => $modulepath,
        'module_repository' => $module_repository,
        'pluginsync'        => $pluginsync,
        'server'            => $certname,
        'ssldir'            => $ssldir,
        'vardir'            => $vardir,
      },
      'master' => {
        'user'              => $user,
        'group'             => $group,
        'trusted_node_data' => versioncmp($::puppetversion, '3.4.0') >= 0,
      }
    }
  }

  sys::inifile { $config_file:
    config  => $config_hash,
    header  => '# Autogenerated by puppet::master; do not modify.',
    indent  => 4,
    owner   => $user,
    group   => $group,
    mode    => '0640',
    notify  => Service['apache'],
    require => [File[$confdir],
                File[$manifestdir],
                File[$modulepath],
                File[$ssldir],
                File[$vardir],
                File[$logdir],
                File[$hiera_config]],
  }

  # Generate CA and certificates for the Puppet Master if they don't exist.
  exec { 'puppet-generate-certs':
    command     => "puppet cert generate ${certname}",
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin', '/usr/local/bin'],
    creates     => "${ssldir}/ca",
    user        => 'root',
    subscribe   => Sys::Inifile[$config_file],
  }
}
