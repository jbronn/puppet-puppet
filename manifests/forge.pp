# == Class: puppet::forge
#
# Installs a private implementation of the Puppet Forge using django-forge.
#
# === Parameters
#
# [*root*]
#  The root directory (FORGE_ROOT) for django-forge's files.  Defaults to
#  '/var/forge'.
#
# [*ssl_cert*]
#  The path of the SSL certificate file; requires `ssl_key` parameter.
#
# [*ssl_key*]
#  The path of the SSL private key file; requires `ssl_cert` parameter.
#
# [*ssl_chain*]
#  The path of the SSL certificate chain file, undefined by default.
#
# [*processes*]
#  The number of processes to allocate to mod_wsgi, defaults to 5.
#
# [*hsts*]
#  Whether or not to enable HTTP Strict Transport Security.  By default
#  this is disabled (due to bad clients like librarian-puppet that
#  can't handle it).
#
# [*server_name*]
#  The `ServerName` configuration value for Apache.
#
# [*server_admin*]
#  The `ServerAdmin` configuration value for Apache.
#
# [*template*]
#  The template to use to generate the Apache site configuration file,
#  defaults to 'puppet/forge/forge.conf.erb'.
#
class puppet::forge(
  $root         = '/var/forge',
  $ssl_cert     = undef,
  $ssl_key      = undef,
  $ssl_chain    = undef,
  $processes    = '5',
  $hsts         = false,
  $server_name  = $::fqdn,
  $server_admin = "admin@${::domain}",
  $template     = undef,
) {
  # Install Apache, Python, Django, and mod_wsgi.
  include apache::params
  include apache::wsgi
  include python::params
  include python::django

  package { 'django-forge':
    ensure   => installed,
    provider => 'pip',
    require  => Class['python::django'],
  }

  # Variable setup.
  $path = ['/usr/local/bin', '/usr/bin']
  $django = "${python::params::site_packages}/django"
  $forge = "${python::params::site_packages}/forge"
  $forge_apache = "${forge}/apache"
  $forge_wsgi = "${forge_apache}/django.wsgi"

  $dbroot = "${root}/db"
  $db = "${dbroot}/forge.db"
  $releases = "${root}/releases"
  $static = "${root}/static"
  $site = "${apache::params::sites_available}/forge"

  # We support SSL and HSTS (optional).
  if $ssl_cert and $ssl_key {
    apache::module { 'ssl':
      ensure => enabled,
      before => Apache::Site['forge'],
    }

    if $hsts {
      include apache::hsts
      Class['apache::hsts'] -> Apache::Site['forge']

      apache::module { 'rewrite':
        ensure => enabled,
        before => Apache::Site['forge'],
      }
    }
  }

  file { $root:
    ensure  => directory,
    owner   => 'root',
    group   => $apache::params::group,
    mode    => '0640',
  }

  file { $dbroot:
    ensure  => directory,
    owner   => $apache::params::user,
    group   => $apache::params::group,
    mode    => '0600',
  }

  file { $releases:
    ensure  => directory,
    owner   => $apache::params::user,
    group   => $apache::params::group,
    mode    => '0640',
  }

  $releases_link = "${forge}/releases"
  file { $releases_link:
    ensure  => link,
    target  => $releases,
    require => Package['django-forge'],
  }

  $db_link = "${forge}/db"
  file { $db_link:
    ensure  => link,
    target  => $dbroot,
    require => Package['django-forge'],
  }

  file { $static:
    ensure  => link,
    target  => "${django}/contrib/admin/static",
    require => Class['python::django'],
  }

  exec { 'create-forge-database':
    command => 'django-admin.py syncdb --settings=forge.settings --noinput',
    path    => $path,
    user    => 'root',
    creates => $db,
    require => [File[$releases_link], File[$db_link]],
  }

  # Ensure settings files are only readable by the apache user.
  file { "${python::site_packages}/forge/settings.py":
    ensure  => file,
    backup  => false,
    owner   => $apache::params::user,
    group   => $apache::params::group,
    mode    => '0600',
    notify  => Service['apache'],
    require => Package['django-forge'],
  }

  file { "${python::site_packages}/forge/settings_secret.py":
    ensure  => file,
    backup  => false,
    owner   => $apache::params::user,
    group   => $apache::params::group,
    mode    => '0600',
    notify  => Service['apache'],
    require => Exec['create-forge-database'],
  }

  file { $db:
    ensure  => file,
    owner   => $apache::params::user,
    group   => $apache::params::group,
    mode    => '0600',
    require => Exec['create-forge-database'],
  }

  if $template {
    $site_template = $template
  } elsif $hsts and $ssl_cert and $ssl_key {
    $site_template = 'puppet/forge/forge_hsts.conf.erb'
  } else {
    $site_template = 'puppet/forge/forge.conf.erb'
  }

  apache::site { 'forge':
    ensure  => enabled,
    content => template($site_template),
    require => Exec['create-forge-database'],
  }

  apache::site { 'default':
    ensure  => disabled,
    require => Apache::Site['forge'],
  }
}
