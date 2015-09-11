# == Class: puppet::user
#
# Creates a user for running Puppet software as a daemon.
#
class puppet::user(
  $ensure = 'present',
  $home   = $puppet::params::vardir,
  $gid    = $puppet::params::gid,
  $uid    = $puppet::params::uid,
  $shell  = '/bin/false',
) inherits puppet::params {
  case $ensure {
    'absent': {
      user { $puppet::params::user:
        ensure => absent,
      }

      group { $puppet::params::group:
        ensure  => absent,
        require => User[$puppet::params::user],
      }
    }
    'present': {
      # Puppet user/group settings.
      group { $puppet::params::group:
        ensure => present,
        gid    => $gid,
      }

      user { $puppet::params::user:
        ensure  => present,
        uid     => $uid,
        gid     => $gid,
        home    => $home,
        shell   => $shell,
        require => Group[$group],
      }
    }
    default: {
      fail('Invalid ensure value.')
    }
  }
}
