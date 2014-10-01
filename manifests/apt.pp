# == Classs: puppet::apt
#
# Installs the GPG key and configures the source list for packages
# from Puppet Labs.
#
class puppet::apt(
  $url          = 'http://apt.puppetlabs.com/',
  $distribution = $::lsbdistcodename,
  $gpg_source   = 'puppet:///modules/puppet/apt/puppetlabs.gpg',
) {
  include sys::apt::update

  sys::apt::key { $gpg_source:
    ensure => present,
  }

  $sources = "${sys::apt::sources_d}/puppetlabs.list"
  sys::apt::sources { $sources:
    repositories => [
      {
        'uri'          => $url,
        'distribution' => $distribution,
        'components'   => ['main'],
      },
      {
        'uri'          => $url,
        'distribution' => $distribution,
        'components'   => ['dependencies'],
      },
    ],
    source       => false,
    require      => Sys::Apt::Key[$gpg_source],
    notify       => Class['sys::apt::update'],
  }

  anchor { 'puppet::apt':
    require => Class['sys::apt::update'],
  }
}
