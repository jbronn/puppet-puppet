# == Class: puppet::master::apache
#
# Configures Apache to run the Puppet Master via Phusion Passenger.
#
class puppet::master::apache(
  $install_type   = 'gem',
  $max_requests   = 1000,
  $max_pool_size  = inline_template(
    "<%= Integer(1.5 * Integer(scope['::processorcount'])) %>"
  ),
  $pool_idle_time = 1500,
) {
  # Configure Phusion Passenger as recommended by Pro Puppet.
  class { '::apache::passenger':
    install_type   => $install_type,
    max_requests   => $max_requests,
    max_pool_size  => $max_pool_size,
    pool_idle_time => $pool_idle_time,
  }

  if $install_type == 'apt' {
    package { 'puppetmaster-passenger':
      ensure  => installed,
      before  => Class['puppet::master::rack'],
      require => Class['::apache::passenger'],
    }
  }

  include puppet::master::rack

  # So Apache user can read puppet files.
  user { $::apache::params::user:
    ensure  => present,
    groups  => [$puppet::master::group],
    require => [Class['::apache::install'],
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
  apache::site { 'puppetmaster':
    ensure  => present,
    content => template('puppet/master/puppetmaster.conf.erb'),
    require => Class['::apache::passenger', 'puppet::master::rack'],
  }

  # OS-dependent settings.
  case $::osfamily {
    debian: {
      # Only listen on port 8140.
      file { "${::apache::params::server_root}/ports.conf":
        ensure  => file,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => "\n",
        require => Class['::apache::install'],
        notify  => Service[$::apache::params::service],
      }
    }
    default: {
      fail("Can't install the Puppet Master with Apache on ${::osfamily}.\n")
    }
  }
}
