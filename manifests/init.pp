# == Class: puppet
#
# This class installs puppet.  Other classes in this module configure
# the puppet master or its agents.
#
class puppet(
  $gem            = $puppet::params::gem,
  $package        = $puppet::params::package,
  $version        = $puppet::params::version,
  $facter_version = $puppet::params::facter_version,
  $hiera_version  = $puppet::params::hiera_version,
  $json_version   = $puppet::params::json_version,
) inherits puppet::params {
  include ruby

  if $gem {
    # Install Puppet and prerequisites via gem.
    package { 'facter':
      ensure   => $facter_version,
      provider => 'gem',
      require  => Class['ruby'],
    }

    package { 'json_pure':
      ensure   => $json_version,
      provider => 'gem',
      require  => Class['ruby'],
    }

    package { 'hiera':
      ensure   => $hiera_version,
      provider => 'gem',
      require  => Package['json_pure'],
    }

    package { 'puppet':
      ensure   => $version,
      provider => 'gem',
      require  => [Class['ruby'], Package['facter'], Package['hiera']],
    }

    # Uninstall old gem versions of Puppet/Facter automatically.
    exec { 'puppet-cleanup':
      command     => 'gem cleanup puppet facter hiera json_pure',
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      subscribe   => [Package['puppet'], Package['facter']],
    }
  } elsif $package {
    # Install Puppet via OS package.
    package { $package:
      ensure  => installed,
      alias   => 'puppet',
      require => Class['ruby'],
    }
  } else {
    fail("Unable to install Puppet on ${::operatingsystem}.\n")
  }
}
