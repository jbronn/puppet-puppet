# == Class: puppet::install::gem
#
# Installs Puppet via Ruby Gems.
#
class puppet::install::gem(
  $cleanup = true,
) {
  include ruby

  package { 'facter':
    ensure   => $puppet::facter_version,
    provider => 'gem',
    require  => Class['ruby'],
  }

  package { 'json_pure':
    ensure   => $puppet::json_version,
    provider => 'gem',
    require  => Class['ruby'],
  }

  package { 'hiera':
    ensure   => $puppet::hiera_version,
    provider => 'gem',
    require  => Package['json_pure'],
  }

  if ($version == 'installed' or versioncmp($version, '3.2.0') >= 0) {
    # Puppet 3.2+ requres rgen.
    package { 'rgen':
      ensure   => $puppet::rgen_version,
      provider => 'gem',
      require  => Class['ruby'],
      before   => Package['puppet'],
    }

    $puppet_packages = ['puppet', 'facter', 'json_pure', 'hiera', 'rgen']
  } else {
    $puppet_packages = ['puppet', 'facter', 'json_pure', 'hiera']
  }

  package { 'puppet':
    ensure   => $puppet::version,
    provider => 'gem',
    require  => [Class['ruby'], Package['facter', 'json_pure', 'hiera']],
  }

  if $cleanup {
    # Uninstall old gem versions of Puppet/Facter automatically.
    exec { 'puppet-cleanup':
      command     => 'gem cleanup puppet facter hiera json_pure rgen',
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      subscribe   => Package[$puppet_packages],
    }
  }
}
