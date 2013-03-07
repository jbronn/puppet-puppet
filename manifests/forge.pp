# == Class: puppet::forge
#
# Installs a private implementation of the Puppet Forge using django-forge.
#
class puppet::forge() {
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

  $forge_root = '/var/forge'
  $forge_dbroot = "${forge_root}/db"
  $forge_db = "${forge_dbroot}/forge.db"
  $forge_releases = "${forge_root}/releases"
  $forge_static = "${forge_root}/static"
  $forge_site = "${apache::params::sites_available}/forge"

  file { $forge_root:
    ensure  => directory,
    owner   => 'root',
    group   => $apache::params::group,
    mode    => '0640',
  }

  file { $forge_dbroot:
    ensure  => directory,
    owner   => $apache::params::user,
    group   => $apache::params::group,
    mode    => '0600',
  }

  file { $forge_releases:
    ensure  => directory,
    owner   => $apache::params::user,
    group   => $apache::params::group,
    mode    => '0640',
  }

  $releases_link = "${forge}/releases"
  file { $releases_link:
    ensure  => link,
    target  => $forge_releases,
    require => Package['django-forge'],
  }

  $db_link = "${forge}/db"
  file { $db_link:
    ensure  => link,
    target  => $forge_dbroot,
    require => Package['django-forge'],
  }

  file { $forge_static:
    ensure  => link,
    target  => "${django}/contrib/admin/static",
    require => Package['Django'],
  }

  exec { 'create-forge-database':
    command => 'django-admin.py syncdb --settings=forge.settings --noinput',
    path    => $path,
    user    => 'root',
    creates => $forge_db,
    require => [File[$releases_link], File[$db_link]],
  }

  file { $forge_db:
    ensure  => file,
    owner   => $apache::params::user,
    group   => $apache::params::group,
    mode    => '0600',
    require => Exec['create-forge-database'],
  }

  file { $forge_site:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet/forge/forge.conf.erb'),
    notify  => Service['apache'],
    require => [Class['apache::install'], Exec['create-forge-database']],
  }

  apache::site { 'default':
    ensure => disabled,
  }

  apache::site { 'forge':
    ensure  => enabled,
    require => File[$forge_site],
  }
}
