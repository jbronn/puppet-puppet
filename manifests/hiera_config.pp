# == Define: puppet::hiera_config
#
# Create a Hiera configuration yaml file at the location of the title
# of this resource.
#
# === Parameters
#
# [*backends*]
#  An array of possible backends, defaults to ['yaml'].
#
# [*settings*]
#  Hashes of settings to use with each backend, defaults to {}.
#
# [*hierarchy*]
#  Array of strings, where each string is the name of a static or dynamic
#  data source.
#
# [*merge_behavior*]
#  Merge behavior to use. 'native' by default.
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
#  Advanced usage only, defaults to 'puppet/hiera.yaml.erb'.
#
define puppet::hiera_config(
  $backends       = ['yaml'],
  $settings       = {},
  $hierarchy      = [],
  $merge_behavior = 'native',
  $logger         = undef,
  $owner          = undef,
  $group          = undef,
  $mode           = '0600',
  $source         = undef,
  $template       = 'puppet/hiera.yaml.erb',
){
  validate_absolute_path($title)
  validate_array($backends, $hierarchy)
  validate_hash($settings)

  file { $title:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    source  => $source,
    content => template($template),
  }
}
