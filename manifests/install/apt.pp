# == Class: puppet::install::apt
#
# Installs Puppet via Puppet Labs' apt repositories.
#
class puppet::install::apt(
  $common_package = 'puppet-common',
  $facter_package = 'facter',
  $hiera_package  = 'hiera',
  $rgen_package   = 'ruby-rgen',
  $suffix         = '1puppetlabs1'
) {
  if $::osfamily != 'Debian' {
    fail("Can only install Puppet with apt on Debian platforms.\n")
  }

  if $puppet::facter_version =~ /-/ {
    $facter_version = $puppet::facter_version
  } else {
    $facter_version = "${puppet::facter_version}-${suffix}"
  }

  if $puppet::hiera_version =~ /-/ {
    $hiera_version = $puppet::hiera_version
  } else {
    $hiera_version = "${puppet::hiera_version}-${suffix}"
  }

  if $puppet::version =~ /-/ {
    $puppet_version = $puppet::version
  } else {
    $puppet_version = "${puppet::version}-${suffix}"
  }

  include puppet::apt

  package { $facter_package:
    ensure  => $facter_version,
    require => Class['puppet::apt'],
  }

  package { $hiera_package:
    ensure  => $hiera_version,
    require => Class['puppet::apt'],
  }

  package { $common_package:
    ensure  => $puppet_version,
    require => Package[$facter_package, $hiera_package],
  }

  package { $puppet::package:
    ensure  => $puppet_version,
    require => Package[$common_package],
  }
}
