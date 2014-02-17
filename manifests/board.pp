# == Class: puppet::board
#
# Experimental class for installing puppetboard, deployed with Apache and
# mod_wsgi.  Requires the counsyl-python module.
#
# === Parameters
#
# TODO
#
# === Example
#
# Configures Puppetboard, assumes you have a running PuppetDB installation and
# have generated SSL keys to communicate with it:
#
#   class { 'puppet::board':
#     puppetdb_host       => 'puppetdb.mydomain.com',
#     puppetdb_port       => '8081',
#     puppetdb_cert       => '/etc/ssl/certs/puppetboard_cert.pem',
#     puppetdb_key        => '/etc/ssl/private/puppetdb_cert.pem',
#     puppetdb_ssl_verify => '/etc/ssl/certs/ca_crt.pem', # From Puppet CA.
#     unresponsive_hours  => 72,
#   }
#
class puppet::board(
  $package              = 'puppetboard',
  $version              = 'installed',
  $provider             = 'pip',
  $root                 = '/var/lib/puppetboard',
  $enable_query         = true,
  $hsts                 = false,
  $log_level            = 'info',
  $puppetdb_cert        = undef,
  $puppetdb_host        = 'localhost',
  $puppetdb_key         = undef,
  $puppetdb_port        = 8080,
  $puppetdb_ssl_verify  = false,
  $puppetdb_timeout     = 20,
  $server_name          = $::fqdn,
  $server_admin         = "admin@${::domain}",
  $ssl_cert             = undef,
  $ssl_key              = undef,
  $template             = undef,
  $threads              = 5,
  $unresponsive_hours   = 2,
  $vhost_extra          = undef,
  $vhost_name           = '_default_',
  $vhost_http_port      = 80,
  $vhost_https_port     = 443,
) {
  include apache
  include apache::wsgi
  include python

  # XXX: Allow customization of the user / group that run puppetboard.
  $user = $apache::params::user
  $group = $apache::params::group

  ## Puppetboard configuration

  # Install puppetboard (done via pip, by default).
  package { $package:
    ensure   => $version,
    provider => $provider,
    require  => Class['python'],
  }

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
    group   => $group,
    mode    => '0640',
    content => template('puppet/board/settings.py.erb'),
    notify  => Service['apache'],
    require => Package[$package],
  }

  # Puppetboard WSGI file, place in `apache` subdirectory of the root.
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
    notify  => Service['apache'],
    require => File[$settings],
  }

  ## Apache configuration

  # Where puppetboard is installed globally and its static files.
  $puppetboard = "${python::params::site_packages}/puppetboard"
  $static = "${puppetboard}/static"

  if $ssl_cert and $ssl_key {
    $ssl = true
    apache::module { 'ssl':
      ensure => enabled,
      before => Apache::Site['puppetboard'],
    }

    if $hsts {
      include apache::hsts
      Class['apache::hsts'] -> Apache::Site['puppetboard']

      apache::module { 'rewrite':
        ensure => enabled,
        before => Apache::Site['puppetboard'],
      }
    }
  } else {
    $ssl = false
  }

  # If there's a custom virtual host configuration template, use it.
  if $template {
    $site_template = $template
  } else {
    $site_template = 'puppet/board/apache.conf.erb'
  }

  apache::site { 'puppetboard':
    ensure  => enabled,
    content => template($site_template),
    require => File[$puppetboard_wsgi],
  }

  apache::site { 'default':
    ensure  => disabled,
    require => Apache::Site['puppetboard'],
  }
}
