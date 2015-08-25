# == Class: puppet::r10k
#
# Installs r10k, using Ruby Gems by default.
#
# === Parameters
#
# [*ensure*]
#  Ensure value for the r10k package resource, defaults to 'installed'.
#
# [*package*]
#  The name of the r10k package resource, defaults to 'r10k'.
#
# [*provider*]
#  The provider of the r10k package resource, defaults to 'gem'.
#
class puppet::r10k(
  $ensure   = 'installed',
  $package  = 'r10k',
  $provider = 'gem',
) {
  include ruby

  package { $package:
    ensure   => $ensure,
    provider => $provider,
    require  => Class['ruby'],
  }
}
