# == Class: puppet
#
# This class installs puppet.  Other classes in this module configure
# the puppet master or its agents.
#
# === Parameters
#
# [*gem*]
#  Whether to install Puppet from gem, defaults to true.
#
# [*package*]
#  If `$gem` is false, then the name of the package to install
#  Puppet from.
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
#  to 'installed'.
#
# [*rgen_version*]
#  The ensure value for the rgen gem package resource, defaults to
#  'installed'.
#
class puppet(
  $gem            = $puppet::params::gem,
  $package        = $puppet::params::package,
  $version        = $puppet::params::version,
  $facter_version = $puppet::params::facter_version,
  $hiera_version  = $puppet::params::hiera_version,
  $json_version   = $puppet::params::json_version,
  $rgen_version   = $puppet::params::rgen_version,
) inherits puppet::params {
  include ruby

  if $gem {
    # Install Puppet and prerequisites via gem.  Because different versions
    # of Puppet require different gems (e.g., Puppet 3 uses Hiera), we need
    # to declare arrays used to construct proper dependency variables.
    package { 'facter':
      ensure   => $facter_version,
      provider => 'gem',
      require  => Class['ruby'],
    }

    $facter_require = [Package['facter']]

    if ($version == 'installed' or versioncmp($version, '3.0.0') >= 0) {
      # Puppet 3.0+ requires hiera and json_pure gems.
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

      $hiera_require = [Package['hiera'], Package['json_pure']]

      if ($version == 'installed' or versioncmp($version, '3.2.0') >= 0) {
        # Puppet 3.2+ requres rgen.
        package { 'rgen':
          ensure   => $rgen_version,
          provider => 'gem',
          require  => Class['ruby'],
        }

        $rgen_require = [Package['rgen']]
      } else {
        $rgen_require = []
      }
    } else {
      $hiera_require = []
      $rgen_require  = []
    }

    # Using the `flatten()` function from the stdlib to properly set up the
    # the `$puppet_require` and `$cleanup_subscribe` lists.
    $puppet_require = flatten(
      [Class['ruby'], $facter_require, $hiera_require, $rgen_require]
    )
    $cleanup_subscribe = flatten(
      [Package['puppet'], $facter_require, $hiera_require, $rgen_require]
    )

    package { 'puppet':
      ensure   => $version,
      provider => 'gem',
      require  => $puppet_require,
    }

    # Uninstall old gem versions of Puppet/Facter automatically.
    exec { 'puppet-cleanup':
      command     => 'gem cleanup puppet facter hiera json_pure',
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      subscribe   => $cleanup_subscribe,
    }
  } elsif $package {
    # Install Puppet via OS package.
    package { $package:
      ensure  => $version,
      alias   => 'puppet',
      require => Class['ruby'],
    }
  } else {
    fail("Unable to install Puppet on ${::operatingsystem}.\n")
  }
}
