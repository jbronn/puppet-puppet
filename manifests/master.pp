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
#  Advanced parameter to overide the hash used to create the puppet.conf
#  with `sys::inifile` resource.
#
# [*main_extra*]
#  Advanced option of extra options to merge with the default options
#  for the 'main' section of puppet.conf.  Does not work with `config`
#  parameter.
#
# [*master_extra*]
#  Advanced parameter of extra options to merge with the default options
#  for the 'master' section of puppet.conf.  Does not work with `config`
#  parameter.
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
  $main_extra         = {},
  $master_extra       = {},
  $ssl_ciphers        = $puppet::params::ssl_ciphers,
  $ssl_protocols      = $puppet::params::ssl_protocols,
) inherits puppet::params {

  # Puppet itself is required first.
  include puppet

  # Alias $home to $vardir.
  $home = $vardir

  # Puppet user/group settings.
  group { $group:
    ensure  => present,
    gid     => $gid,
    before  => Class['puppet::master::apache'],
    require => Class['puppet'],
  }

  user { $user:
    ensure  => present,
    uid     => $uid,
    gid     => $gid,
    home    => $home,
    shell   => '/bin/false',
    before  => Class['puppet::master::apache'],
    require => Group[$group],
  }

  include puppet::master::apache

  ## Puppet directories ##
  file { $confdir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => $confdir_mode,
  }

  file { $manifestdir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => $manifestdir_mode,
  }

  file { $modulepath:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => $modulepath_mode,
  }

  file { $ssldir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    # Puppet always changes mode to this, not going to fight it.
    mode    => '0661',
  }

  file { $vardir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0640',
  }

  file { $logdir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0640',
  }

  file { $hiera_datadir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
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
    # Default configuration for 'main' section of puppet.conf.
    $main_config = {
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
    }

    # Default configuration for 'master' section of puppet.conf.
    $master_config = {
      'user'              => $user,
      'group'             => $group,
      'trusted_node_data' => versioncmp($::puppetversion, '3.4.0') >= 0,
    }

    # Constructing the puppet.conf inifile configuration hash with any
    # 'extra' options (if specified).
    $config_hash = {
      'main'   => merge($main_config, $main_extra),
      'master' => merge($master_config, $master_extra),
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
  # This should not be necessary where Puppet Master / Passenger are
  # installed via apt.
  exec { 'puppet-generate-certs':
    command     => "puppet cert generate ${certname}",
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin', '/usr/local/bin'],
    creates     => "${ssldir}/ca",
    user        => 'root',
    subscribe   => Sys::Inifile[$config_file],
  }
}
