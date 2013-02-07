# == Class: puppet::master::apache
#
# Configures Apache to run the Puppet Master via Phusion Passenger.
#
class puppet::master::apache {
  class { 'apache::passenger':
    # As recommended in Pro Puppet, they be leaking.
    max_requests => '4000',
  }

  include puppet::master::rack

  # So Apache user can read puppet files.
  user { $apache::params::user:
    ensure  => present,
    groups  => [$puppet::master::group],
    require => [Class['apache::install'],
                Group[$puppet::master::group]],
  }

  # Ensure that the ssl and header modules are enabled.
  apache::module { 'headers':
    ensure  => present,
  }

  apache::module { 'ssl':
    ensure  => present,
  }

  # Ensure default sites are disabled.
  apache::site { 'default':
    ensure  => absent,
  }

  apache::site { 'default-ssl':
    ensure  => absent,
  }

  # Create Puppet Master site configuration and enable it.
  $puppetmaster = "${apache::params::sites_available}/puppetmaster"
  file { $puppetmaster:
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('puppet/master/puppetmaster.conf.erb'),
  }

  apache::site { 'puppetmaster':
    ensure  => present,
    require => [Class['apache::passenger::config'],
                Class['puppet::master::rack'],
                File[$puppetmaster]],
  }

  # OS-dependent settings.
  case $::osfamily {
    debian: {
      # Only listen on port 8140.
      file { "${apache::params::server_root}/ports.conf":
        ensure  => file,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => "\n",
        require => Class['apache::install'],
        notify  => Service['apache'],
      }
    }
    redhat: {
      include puppet::master::redhat
    }
    default: {
      fail("Can't install the Puppet Master with Apache on ${::osfamily}.\n")
    }
  }
}
