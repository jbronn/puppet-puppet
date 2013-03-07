# == Define: puppet::hiera_config
#
# Create a Hiera configuration yaml file.
#
# === Parameters
#
# [*name*]
#  Required: the filename of the configuration file.
#
# [*backends*]
#  Defaults to 'yaml', but can also be an array.
#
# [*settings*]
#  Hashes of settings to use with each backend.
#
# [*hierarchy*]
#  Must be a string or an array of strings, where each string is the name
#  of a static or dynamic data source.
#
# [*logger*]
#  The logger for hiera to use, undefined by default.
#
# [*owner*]
#  Owner of hiera yaml file, undefined by default.
#
# [*group*]
#  Group of hiera yaml file, undefined by default.
#
# [*mode*]
#  Mode of hiera yaml file, defaults to '0600'.
#
# [*template*]
#  Advanced usage only.  Defaults to 'puppet/hiera.yaml.erb'.
#
define puppet::hiera_config(
  $backends  = 'yaml',
  $settings  = undef,
  $hierarchy = undef,
  $logger    = undef,
  $owner     = undef,
  $group     = undef,
  $mode      = '0600',
  $source    = undef,
  $template  = 'puppet/hiera.yaml.erb',
){
  file { $name:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    source  => $source,
    content => template($template),
  }
}
