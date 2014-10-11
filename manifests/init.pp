# == Class: puppet
#
# This class installs puppet.  Other classes in this module configure
# the puppet master or its agents.
#
# === Parameters
#
# [*install_type*]
#
# [*package*]
#
# [*version*]
#  The ensure value for the Puppet package resource, defaults
#  to 'installed'.
#
# [*facter_version*]
#  The ensure value for the Facter gem package resource, defaults
#  to 'installed'.
#
# [*hiera_version*]
#  The ensure value for the Hiera gem package resource, defaults
#  to 'installed'.
#
# [*json_version*]
#  The ensure value for the json_pure gem package resource, defaults
#  to 'installed'.  Only applicable when installing via Ruby Gems.
#
# [*rgen_version*]
#  The ensure value for the rgen gem package resource, defaults to
#  'installed'.  Only applicable when installing via Ruby Gems.
#
class puppet(
  $install_type   = $puppet::params::install_type,
  $package        = $puppet::params::package,
  $version        = $puppet::params::version,
  $facter_version = 'installed',
  $hiera_version  = 'installed',
  $json_version   = 'installed',
  $rgen_version   = 'installed',
) inherits puppet::params {
  anchor { 'puppet::install': }

  case $install_type {
    'apt': {
      include puppet::install::apt
      Class['puppet::install::apt'] -> Anchor['puppet::install']
    }
    'gem': {
      include puppet::install::gem
      Class['puppet::install::gem'] -> Anchor['puppet::install']
    }
    'openbsd': {
      include puppet::install::openbsd
      Class['puppet::install::openbsd'] -> Anchor['puppet::install']
    }
    default: {
      fail("Unable to install Puppet on ${::operatingsystem}.\n")
    }
  }
}
