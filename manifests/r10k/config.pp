# == Define: puppet::r10k::config
#
# Generates a
#
# === Parameters
#
# [*cachedir*]
#  The path to use for the r10k cache directory, false by default.
#
# [*forge*]
# 
# [*owner*]
#  Owner of r10k config file, undefined by default.
#
# [*group*]
#  Group of r10k config file, undefined by default.
#
# [*mode*]
#  Mode of r10k config file, defaults to '0600'.
#
# [*template*]
#  Advanced usage only, the template used to generate the r10k
#  configuration file; defaults to 'puppet/r10k/r10k.yaml.erb'.
#
define puppet::r10k::config(
  $cachedir = false,
  $forge    = {},
  $git      = {},
  $sources  = {},
  $postrun  = [],
  $owner    = undef,
  $group    = undef,
  $mode     = '0600',
  $template = 'puppet/r10k/r10k.yaml.erb',
) {
  validate_absolute_path($title)
  validate_array($postrun)
  validate_hash($forge, $git, $sources)

  if is_string($cachedir) {
    validate_absolute_path($cachedir)
  }

  file { $title:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => template($template),
  }
}
