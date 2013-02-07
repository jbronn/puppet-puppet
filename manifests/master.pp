# == Class: puppet::master
#
# Installs the Puppet Master, running behind Apache/Phusion Passenger.
#
# === Parameters
#
# [*certname*]
#   The name of the puppet master, defaults to the node's FQDN.
#
# [*user*]
#   The name of the user to run the Puppet master as.  Defaults to 'puppet'.
#
# [*uid*]
#   The uid to use for the Puppet user.  Defaults to '1001'.
#
# [*group*]
#   The name of the group to run the Puppet master as.  Defaults to 'puppet'.
#
# [*gid*]
#   The gid to use for the Puppet group.  Defaults to '1001'.
#
# [*confdir*]
#   The path of the configuration directory, defaults to '/etc/puppet'.
#
# [*hiera_config*]
#   The Hiera configuration file path, defaults to '/etc/puppet/hiera.yaml'.
#
# [*hiera_datadir*]
#   The path to the Hiera data directory, defaults to '/etc/puppet/hieradata'.
#
# [*manifestdir*]
#   Path for manifests.  Defaults to '/etc/puppet/manifests'.
#
# [*modulepath*]
#   Path for modules.  Defaults to '/etc/puppet/modules'.
#
# [*ssldir*]
#   Where Puppet stores it's SSL certificates.  Defaults to '/etc/puppet/ssl'.
#
# [*vardir*]
#   One of Puppet's main working directories.  Defaults to '/var/lib/puppet'.
#
# [*logdir*]
#   Where the master should stor its logs.  Defaults to '/var/log/puppet'.
#
# [*pluginsync*]
#   Whether or not to enable `pluginsync` in the configuration file.
#   Defaults to true.
#
# [*config*]
#  Advanced option to overide the hash used to create the master
#  `sys::inifile` resource for puppet.conf.
#
class puppet::master(
  $certname          = $puppet::params::certname,
  $user              = $puppet::params::user,
  $uid               = $puppet::params::uid,
  $group             = $puppet::params::group,
  $gid               = $puppet::params::gid,
  $confdir           = $puppet::params::confdir,
  $hiera_config      = $puppet::params::hiera_config,
  $hiera_datadir     = $puppet::params::hiera_datadir,
  $manifestdir       = $puppet::params::manifestdir,
  $modulepath        = $puppet::params::modulepath,
  $module_repository = $puppet::params::module_repository,
  $ssldir            = $puppet::params::ssldir,
  $vardir            = $puppet::params::vardir,
  $logdir            = $puppet::params::logdir,
  $pluginsync        = $puppet::params::pluginsync,
  $config            = undef,
) inherits puppet::params {

  # Required modules.
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
    mode    => '0640',
  }

  file { $manifestdir:
    ensure  => directory,
    mode    => '0640',
  }

  file { $modulepath:
    ensure  => directory,
    mode    => '0640',
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
    mode    => '0640',
  }

  ## Puppet configuration files ##

  # Hiera configuration.
  file { $hiera_config:
    ensure  => file,
    mode    => '0600',
    content => template('puppet/master/hiera.yaml.erb'),
    notify  => Service['apache'],
    require => File[$hiera_datadir],
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
        'certname'     => $certname,
        'confdir'      => $confdir,
        'group'        => $group,
        'hiera_config' => $hiera_config,
        'logdir'       => $logdir,
        'manifestdir'  => $manifestdir,
        'modulepath'   => $modulepath,
        'pluginsync'   => $pluginsync,
        'server'       => $certname,
        'ssldir'       => $ssldir,
        'user'         => $user,
        'vardir'       => $vardir,
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

  # Generate CA and certificates for the Puppet Master
  # if they don't exist.
  exec { 'puppet-generate-certs':
    # XXX: `puppet cert` command is deprecated in the future.
    command     => "puppet cert generate ${certname}",
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    unless      => "test -d ${ssldir}/ca",
    refreshonly => true,
    user        => 'root',
    subscribe   => Sys::Inifile[$config_file],
  }
}
