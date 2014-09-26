# == Class: puppet::install::openbsd
#
# Installs Puppet on OpenBSD systems.
#
class puppet::install::openbsd {
  include ruby
  package { $puppet::package:
    ensure  => $puppet::version,
    require => Class['ruby'],
  }
}
