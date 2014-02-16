# == Class: puppet::board
#
# Installs puppetboard.
#
class puppet::board(
  $package              = 'puppetboard',
  $version              = 'installed',
  $provider             = 'pip',
  $root                 = '/var/puppetboard',
  $user                 = undef,
  $puppetdb_host        = 'localhost',
  $puppetdb_port        = '8080',
  $puppetdb_ssl_verify  = false,
  $puppetdb_key         = undef,
  $puppetdb_cert        = undef,
  $puppetdb_timeout     = '20',
  $unresponsive_hours   = '2',
  $enable_query         = true,
  $loglevel             = 'info',
  $server_name          = $::fqdn,
  $server_admin         = "admin@${::domain}",
  $hsts                 = false,
  $ssl_key              = undef,
  $ssl_cert             = undef,
  $threads              = '5',
  $vhost_name           = '_default_',
  $vhost_http_port      = '80',
  $vhost_https_port     = '443',
) {
  include apache
  include apache::wsgi
  include python

  # Install puppetboard, by default via pip.
  package { $package:
    ensure   => $version,
    provider => $provider,
  }

  # Where puppetboard is installed globally and its static files.
  $puppetboard = "${python::params::site_packages}/puppetboard"
  $static = "${puppetboard}/static"

  file { $root:
    ensure => directory,
    owner  => 'root',
    group  => $apache::params::group,
    mode   => '0640',
  }
  
  # Puppetboard settings files.
  $settings = "${root}/settings.py"
  file { $settings:
    ensure  => file,
    owner   => 'root',
    group   => $apache::params::group,
    mode    => '0640',
    content => template('puppet/board/settings.py.erb'),
    notify  => Service['apache'],
  }

  # Puppetboard WSGI file, place in `apache` subdirectory.
  $apache_dir = "${root}/apache"
  file { $apache_dir:
    ensure => directory,
    owner  => 'root',
    group  => $apache::params::group,
    mode   => '0640',
  }

  $puppetboard_wsgi = "${apache_dir}/wsgi.py"
  file { $puppetboard_wsgi:
    ensure  => file,
    owner   => 'root',
    group   => $apache::params::group,
    mode    => '0640',
    content => template('puppet/board/wsgi.py.erb'),
  }

  if $ssl_cert and $ssl_key {
    $ssl = true
    
    apache::module { 'ssl':
      ensure => enabled,
      #before => Apache::Site['forge'],
    }

    if $hsts {
      include apache::hsts
      #Class['apache::hsts'] -> Apache::Site['forge']

      apache::module { 'rewrite':
        ensure => enabled,
        #before => Apache::Site['forge'],
      }
    }
  } else {
    $ssl = false
  }

}
