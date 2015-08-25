# == Class: puppet::master::rack
#
# Provides files and directories necessary to run the Puppet Master with Rack
# and Phusion Passenger.
#
class puppet::master::rack {
  $conf = "${puppet::master::confdir}/rack"
  file { $conf:
    ensure => directory,
    owner  => 'root',
    group  => $puppet::master::group,
    mode   => '0640',
  }

  $puppetmaster = "${conf}/puppetmaster"
  file { $puppetmaster:
    ensure => directory,
    owner  => 'root',
    group  => $puppet::master::group,
    mode   => '0640',
  }

  file { "${puppetmaster}/public":
    ensure => directory,
    owner  => 'root',
    group  => $puppet::master::group,
    mode   => '0640',
  }

  file { "${puppetmaster}/tmp":
    ensure => directory,
    owner  => 'root',
    group  => $puppet::master::group,
    mode   => '0640',
  }

  file { "${puppetmaster}/config.ru":
    ensure  => file,
    owner   => $puppet::master::user,
    group   => $puppet::master::group,
    mode    => '0640',
    content => template('puppet/master/config.ru.erb'),
  }
}
