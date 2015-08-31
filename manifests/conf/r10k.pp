class puppet::conf::r10k(
  $group    = $puppet::params::group,
  $mode     = '0640',
  $settings = {},
) inherits puppet::params {

  include puppet::conf::puppetlabs

  file { $puppet::params::r10k_confdir:
    ensure  => directory,
    owner   => 'root',
    group   => $group,
    mode    => $mode,
    require => Class['puppet::conf::puppetlabs'],
  }

  create_resources('puppet::r10k::config',
    {
      $puppet::params::r10k_config_file => $settings
    }
  )
}
