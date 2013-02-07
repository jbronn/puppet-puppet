# == Class: puppet::forge
#
# Experimental.
#
class puppet::forge() {
  if $::operatingsystem != 'Ubuntu' or $::lsbmajdistrelease < 12 {
    fail('Only supported on Ubuntu 12.04 and above.')
  }

  # Variable setup.
  $path = ['/usr/local/bin', '/usr/bin']
  $pythonlib = '/usr/local/lib/python2.7/dist-packages'
  $django = "${pythonlib}/django"
  $forge = "${pythonlib}/forge"
  $db_dir = "${forge}/db"
  $forge_db = "${db_dir}/forge.db"
  $forge_www = '/var/www/forge'
  $forge_releases = "${forge_www}/releases"
  $forge_static = "${forge_www}/static"
  $forge_site = "${apache::params::sites_available}/forge"

  $tarball = 'django-forge-0.4.0.tar.gz'
  $tarball_path = "/root/${tarball}"

  # XXX: Until `python` module is ported, can't use apache::wsgi.
  include apache
  package { 'python':
    ensure => installed,
  }

  package { 'python-pip':
    ensure  => installed,
    require => Package['python'],
  }

  package { 'Django':
    ensure   => installed,
    provider => 'pip',
    require  => Package['python-pip'],
  }

  package { 'libapache2-mod-wsgi':
    ensure  => installed,
    alias   => 'mod_wsgi',
    require => [Class['apache::install'],
                Package['python']],
  }

  # Ensure mod_wsgi is enabled.
  apache::module { 'wsgi':
    ensure  => enabled,
    require => Package['mod_wsgi'],
  }

  file { $tarball_path:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    source  => "puppet:///modules/puppet/forge/${tarball}",
  }

  file { [$forge_www, $forge_releases]:
    ensure  => directory,
    owner   => $apache::params::user,
    group   => $apache::params::group,
    mode    => '0640',
    require => Class['apache::install'],
  }

  exec { 'install-django-forge':
    command     => "pip install -I ${tarball}",
    path        => $path,
    cwd         => '/root',
    user        => 'root',
    subscribe   => File[$tarball_path],
    refreshonly => true,
    require     => [ File[$tarball_path], Package['Django'] ],
  }

  $releases_link = "${forge}/releases"
  file { $releases_link:
    ensure  => link,
    target  => $forge_releases,
    require => Exec['install-django-forge'],
  }

  file { $forge_static:
    ensure  => link,
    target  => "${django}/contrib/admin/static",
    require => Package['Django'],
  }

  file { $db_dir:
    ensure  => directory,
    owner   => $apache::params::user,
    group   => $apache::params::user,
    mode    => '0600',
    require => Exec['install-django-forge'],
  }

  exec { 'create-forge-database':
    command => 'django-admin.py syncdb --settings=forge.settings --noinput',
    path    => $path,
    user    => 'root',
    creates => $forge_db,
    require => [ File[$releases_link], File[$db_dir] ],
  }

  file { $forge_db:
    ensure  => file,
    owner   => $apache::params::user,
    group   => $apache::params::user,
    mode    => '0600',
    notify  => Service['apache'],
    require => Exec['create-forge-database'],
  }

  file { $forge_site:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet/forge/forge.conf.erb'),
    notify  => Service['apache'],
    require => [ Class['apache::install'], File[$forge_db] ],
  }

  apache::site { 'default':
    ensure => disabled,
  }

  apache::site { 'forge':
    ensure  => enabled,
    require => File[$forge_site],
  }
}
