# == Class: puppet::params
#
# Platform-dependent parameters for Puppet.
#
class puppet::params {
  # User/group settings.
  include sys
  $uid = '580'
  $gid = '580'
  $root_group = $sys::root_group

  # General Puppet configuration settings.
  $certname = $::fqdn
  $confdir = '/etc/puppet'
  $logdir = '/var/log/puppet'
  $hiera_config = "${confdir}/hiera.yaml"
  $hiera_datadir = "${confdir}/hiera"
  $manifestdir = "${confdir}/manifests"
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
      # Peg to versions that we know work.
      $version = '3.1.0'
      $facter_version = '1.6.17'
    }
  }
}
