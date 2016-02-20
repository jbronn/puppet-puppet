# == Class: puppet::install::apt
#
# Installs Puppet via Puppet Labs' apt repositories.
#
class puppet::install::apt(
  $common_package = 'puppet-common',
  $facter_package = 'facter',
  $hiera_package  = 'hiera',
  $suffix         = '1puppetlabs1'
) {
  if $::osfamily != 'Debian' {
    fail('Can only install Puppet with apt on Debian platforms.')
  }

  if $puppet::facter_version =~ /-/ {
    $facter_version = $puppet::facter_version
  } elsif $puppet::facter_version =~ /^(absent|installed|present|uninstalled)$/ {
    $facter_version = $puppet::facter_version
  } else {
    $facter_version = "${puppet::facter_version}-${suffix}"
  }

  if $puppet::hiera_version =~ /-/ {
    $hiera_version = $puppet::hiera_version
  } elsif $puppet::hiera_version =~ /^(absent|installed|present|uninstalled)$/ {
    $hiera_version = $puppet::hiera_version
  } else {
    $hiera_version = "${puppet::hiera_version}-${suffix}"
  }

  if $puppet::version =~ /-/ {
    $puppet_version = $puppet::version
  } elsif $puppet::version =~ /^(absent|installed|present|uninstalled)$/ {
    $puppet_version = $puppet::version
  } else {
    $puppet_version = "${puppet::version}-${suffix}"
  }

  include puppet::apt

  ensure_packages([$facter_package], { 'ensure' => $facter_version })
  ensure_packages([$hiera_package], { 'ensure' => $hiera_version })
  ensure_packages(
    [$common_package, $puppet::package],
    { 'ensure' => $puppet_version }
  )
}
