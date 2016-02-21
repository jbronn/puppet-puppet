# == Class: puppet::master
#
# Installs the Puppet Master, running behind Apache/Phusion Passenger.
#
# === Parameters
#
# [*basemodulepath*]
#  Path for modules, defaults to '/etc/puppetlabs/code/modules'.
#
# [*basemodulepath_mode*]
#  File mode for the base module path, defaults to '0640'.
#
# [*codedir_mode*]
#  File mode for the puppet code directory, defaults to '0640'.
#
# [*certname*]
#  The name of the puppet master, defaults to the node's FQDN.
#
# [*environmentpath*]
#  Path for manifests.  Defaults to '/etc/puppet/manifests'.
#
# [*environmentpath_mode*]
#  File mode for the manifests directory, defaults to '0640'.
#
# [*hiera_backends*]
#  Array of Hiera backends to use, defaults to ['yaml'].
#
# [*hiera_hierarchy*]
#  The hierarchy used by Hiera, defaults to ["'%{::fqdn}'", 'common'].
#
# [*hiera_settings*]
#  The settings hash parameter passed through to the `puppet::hiera_config`
#  resource, the default just specifies the datadir for the YAML backend.
#
# [*logdir*]
#  Where the master should store its logs.  Defaults to '/var/log/puppet'.
#
# [*merge_behavior*]
#  The merge behavior to use for Hiera.
#
# [*ssldir*]
#  Where Puppet stores it's SSL certificates.  Defaults to '/etc/puppet/ssl'.
#
# [*ssl_ciphers*]
#  Array of acceptable SSL ciphers for the master apache instance to use.
#
# [*ssl_protocols*]
#  Array of SSL protocols for the master apache instance to use.
#
# [*vardir*]
#  One of Puppet's main working directories.  Defaults to '/var/lib/puppet'.
#
class puppet::master(
  $basemodulepath       = $puppet::params::basemodulepath,
  $basemodulepath_mode  = '0640',
  $certname             = $::fqdn,
  $codedir_mode         = '0640',
  $environmentpath      = $puppet::params::environmentpath,
  $environmentpath_mode = '0640',
  $hiera_backends       = $puppet::params::hiera_backends,
  $hiera_settings       = $puppet::params::hiera_settings,
  $hiera_hierarchy      = $puppet::params::hiera_hierarchy,
  $logdir               = $puppet::params::logdir,
  $merge_behavior       = $puppet::params::merge_behavior,
  $module_repository    = $puppet::params::module_repository,
  $ssl_ciphers          = $puppet::params::ssl_ciphers,
  $ssl_protocols        = $puppet::params::ssl_protocols,
  $ssldir               = $puppet::params::ssldir,
  $vardir               = $puppet::params::vardir,
) inherits puppet::params {

  # Puppet itself is required first.
  include puppet
  Class['puppet'] -> Class['puppet::user']

  # Ensure the 'deep_merge' gem is available for Hiera
  package { 'deep_merge':
    ensure   => 'installed',
    provider => 'gem',
  }

  # Need puppet user/group.
  include puppet::user
  Class['puppet::user'] -> Class['puppet::master::apache']

  include puppet::master::apache

  ## Puppet directories ##
  include puppet::config

  file { $basemodulepath:
    ensure => directory,
    owner  => $puppet::params::user,
    group  => $puppet::params::group,
    mode   => $basemodulepath_mode,
  }

  file { $environmentpath:
    ensure => directory,
    owner  => $puppet::params::user,
    group  => $puppet::params::group,
    mode   => $environmentpath_mode,
  }

  file { $puppet::params::codedir:
    ensure => directory,
    owner  => $puppet::params::user,
    group  => $puppet::params::group,
    mode   => $codedir_mode,
  }

  file { $ssldir:
    ensure => directory,
    owner  => $puppet::params::user,
    group  => $puppet::params::group,
    # Puppet always changes mode to this, not going to fight it.
    mode   => '0661',
  }

  file { $vardir:
    ensure => directory,
    owner  => $puppet::params::user,
    group  => $puppet::params::group,
    mode   => '0640',
  }

  file { $logdir:
    ensure => directory,
    owner  => $puppet::params::user,
    group  => $puppet::params::group,
    mode   => '0640',
  }

  ## Puppet configuration files ##

  # Hiera configuration.
  puppet::hiera_config { $puppet::params::hiera_config:
    backends       => $hiera_backends,
    settings       => $hiera_settings,
    hierarchy      => $hiera_hierarchy,
    merge_behavior => $merge_behavior,
    owner          => $user,
    group          => $group,
    notify         => Service[$::apache::params::service],
    require        => [File[$environmentpath], Package['deep_merge']],
  }

  puppet_setting { 'main/basemodulepath':
    value => $basemodulepath,
  }

  puppet_setting { 'main/certname':
    value => $certname,
  }

  puppet_setting { 'main/confdir':
    value => $puppet::params::confdir,
  }

  puppet_setting { 'main/environmentpath':
    value => $environmentpath,
  }

  puppet_setting { 'main/codedir':
    value => $puppet::params::codedir,
  }

  puppet_setting { 'main/hiera_config':
    value => $puppet::params::hiera_config,
  }

  puppet_setting { 'main/logdir':
    value => $logdir,
  }

  ## Master settings

  $master_settings = {
    'master/user'                     => { 'value' => $puppet::params::user },
    'master/group'                    => { 'value' => $puppet::params::group },
    'master/ssl_client_header'        => { 'value' => 'SSL_CLIENT_S_DN' },
    'master/ssl_client_verify_header' => { 'value' => 'SSL_CLIENT_VERIFY' },
    'master/trusted_node_data'        => { 'value' => true },
  }
  create_resources('puppet_setting', $master_settings)

  # Have puppet.conf refresh apache.
  File[$puppet::params::config_file] ~> Service[$::apache::params::service]

  # Generate CA and certificates for the Puppet Master if they don't exist.
  # This should not be necessary where Puppet Master / Passenger are
  # installed via apt.
  exec { 'puppet-generate-certs':
    command   => "puppet cert generate ${certname}",
    path      => ['/usr/sbin', '/usr/bin', '/sbin', '/bin', '/usr/local/bin'],
    creates   => "${ssldir}/ca",
    user      => 'root',
    subscribe => File[$puppet::params::config_file],
  }
}
