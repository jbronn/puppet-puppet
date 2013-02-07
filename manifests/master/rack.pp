# == Class: puppet::master::rack
#
# Provides files and directories necessary to run the Puppet Master with Rack
# and Phusion Passenger.
#
class puppet::master::rack {
  $rackconf = "${puppet::master::confdir}/rack"
  file { $rackconf:
    ensure  => directory,
    owner   => $puppet::master::user,
    group   => $puppet::master::group,
    mode    => '0640',
  }

  $puppetmaster = "${rackconf}/puppetmaster"
  file { $puppetmaster:
    ensure  => directory,
    owner   => $puppet::master::user,
    group   => $puppet::master::group,
    mode    => '0640',
  }

  file { "${puppetmaster}/public":
    ensure  => directory,
    owner   => $puppet::master::user,
    group   => $puppet::master::group,
    mode    => '0640',
  }

  file { "${puppetmaster}/tmp":
    ensure  => directory,
    owner   => $puppet::master::user,
    group   => $puppet::master::group,
    mode    => '0640',
  }

  if versioncmp($::puppetversion, '3.0.0') >= 0{
    $configtemplate = 'puppet/master/config-3.ru.erb'
  } else {
    $configtemplate = 'puppet/master/config-2.ru.erb'
  }

  file { "${puppetmaster}/config.ru":
    ensure  => file,
    owner   => $puppet::master::user,
    group   => $puppet::master::group,
    mode    => '0640',
    content => template($configtemplate),
  }
}
