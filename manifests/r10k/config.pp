# == Define: puppet::r10k::config
#
# Generates a configuration file for use with r10k.  For more details
# on the configuration file format, consult:
#
#  https://github.com/puppetlabs/r10k/blob/master/doc/dynamic-environments/configuration.mkd
#
# === Parameters
#
# [*cachedir*]
#  The path to use for the r10k cache directory, false by default.
#
# [*forge*]
#  Hash of forge options for r10k, defaults to {}.
#
# [*git*]
#  Hash of git options for r10k, defaults to {}.
#
# [*postrun*]
#  Array of commands to provide for the postrun option, defaults to [].
#
# [*sources*]
#  Hash of the dynamic environment sources for r10k, defaults to {}.
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
  $postrun  = [],
  $sources  = {},
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
