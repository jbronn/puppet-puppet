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
  $logdir = '/var/log/puppet'
  $hiera_config = "${confdir}/hiera.yaml"
  $hiera_datadir = "/var/lib/hiera"
  $manifestdir = "${confdir}/manifests"
  $fileserverconfig = "${confdir}/fileserver.conf"
  $modulepath = "${confdir}/modules"
  $pluginsync = true
  $report = true
  $server = "puppet.${::domain}"
  $ssldir = "${confdir}/ssl"
  $vardir = '/var/lib/puppet'
  $module_repository = 'https://forge.puppetlabs.com'

  case $::osfamily {
    openbsd: {
      # The packaged version works much better than installing
      # from gem on OpenBSD.
      include sys::openbsd::pkg
      $gem = false
      $user = '_puppet'
      $group = '_puppet'
      $package = 'ruby-puppet'
      $source = $sys::openbsd::pkg::source
      $version = $sys::openbsd::pkg::puppet
      $facter_version = $sys::openbsd::pkg::facter
    }
    default: {
      # Try and use gem by default for everybody else.
      $gem = true
      $user = 'puppet'
      $group = 'puppet'
      # Use latest versions at time of installation -- but user
      # isn't stopped from changing class parameter.
      $version = 'installed'
      $facter_version = 'installed'
      $hiera_version = 'installed'
      $json_version = 'installed'
      $rgen_version = 'installed'
    }
  }
}
