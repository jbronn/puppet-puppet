# == Class: puppet::params
#
# Platform-dependent parameters for Puppet.
#
class puppet::params {
  # User/group settings.  The specific UIDs chosen are inspired from
  # OpenBSD, and are in the range of "system" IDs on Ubuntu systems
  # by default (and should be for Illumos variants as well, but not tested).
  include sys
  $uid = '580'
  $gid = '580'
  $root_group = $sys::root_group

  # General Puppet configuration settings.
  $certname = $::fqdn
  $confdir = '/etc/puppet'
  $fileserverconfig = "${confdir}/fileserver.conf"
  $logdir = '/var/log/puppet'
  $manifestdir = "${confdir}/manifests"
  $modulepath = "${confdir}/modules"
  $pluginsync = true
  $report = true
  $server = "puppet.${::domain}"
  $ssldir = "${confdir}/ssl"
  $vardir = '/var/lib/puppet'

  # The following default settings depend on the version of Puppet.
  if versioncmp($::puppetversion, '3.6.0') >= 0 {
    $module_repository = 'https://forgeapi.puppetlabs.com'
  } else {
    $module_repository = 'https://forge.puppetlabs.com'
  }

  # Sensible Hiera default settings, mostly specific to the Puppet master.
  $hiera_config = "${confdir}/hiera.yaml"
  $hiera_datadir = "${confdir}/hiera"
  $hiera_backends = ['yaml']
  $hiera_settings = {
    'yaml'   => {
      'datadir' => $hiera_datadir,
    }
  }
  $hiera_hierarchy = ["'%{::clientcert}'", 'common']
  $merge_behavior = 'deeper'

  # Master configuration variables.
  $ssl_ciphers = [
    'EDH+CAMELLIA', 'EDH+aRSA', 'EECDH+aRSA+AESGCM', 'EECDH+aRSA+SHA384',
    'EECDH+aRSA+SHA256', 'EECDH', '+CAMELLIA256', '+AES256', '+CAMELLIA128',
    '+AES128', '+SSLv3', '!aNULL', '!eNULL', '!LOW', '!3DES', '!MD5', '!EXP',
    '!PSK', '!DSS', '!RC4', '!SEED', '!IDEA', '!ECDSA', 'kEDH',
    'CAMELLIA256-SHA', 'AES256-SHA', 'CAMELLIA128-SHA', 'AES128-SHA'
  ]
  $ssl_protocols = ['ALL', '-SSLv2', '-SSLv3']

  case $::osfamily {
    'Debian': {
      $install_type = 'apt'
      $user = 'puppet'
      $group = 'puppet'
      $package = 'puppet'
      $version = 'installed'
    }
    'OpenBSD': {
      # The packaged version works much better than installing from gem.
      include sys::openbsd::pkg
      $install_type = 'openbsd'
      $user = '_puppet'
      $group = '_puppet'
      $package = 'puppet'

      case $::kernelmajversion {
        '5.7': {
          $version = '3.7.4p0'
        }
        '5.6': {
          $version = '3.6.2p3'
        }
        '5.5': {
          $version = '3.4.2'
        }
        default: {
          fail("Unsupported version of OpenBSD: ${::kernelmajversion}.\n")
        }
      }
    }
    default: {
      # Try and use gem by default for everybody else.
      $install_type = 'gem'
      $user = 'puppet'
      $group = 'puppet'
      # Use latest versions at time of installation -- but user
      # isn't stopped from changing class parameter.
      $version = 'installed'
    }
  }
}
