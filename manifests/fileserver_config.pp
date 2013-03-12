# == Define: puppet::fileserver_config
#
# Generates the Puppet master file server configuration file
# (e.g., /etc/puppet/fileserver.conf).
#
# === Parameters
#
# [*mounts*]
#  A hash expressing the configuration.  Keys are the mounts,
#  values are hashes with ('path','allow','deny') values.
#
# [*owner*]
#  The owner of the fileserver configuration file at $name.
#  Defaults to 'puppet'.
#
# [*group*]
#  The group of the fileserver configuration file at $name.
#  Defaults to 'puppet'.
#
# [*mode*]
#  The mode of the configuration file.  Defaults to '0640'.
#
# [*header*]
#  The header of the configuration file, Defaults to:
#  "# Created by puppet::fileserver_config; do not modify.".
#
# [*template*]
#  The template used to generate the configuration file.  Defaults to:
#  'puppet/master/fileserver.conf.erb'.  Advanced usage only.
#
define puppet::fileserver_config(
  $mounts,
  $owner    = 'puppet',
  $group    = 'puppet',
  $mode     = '0640',
  $header   = '# Created by puppet::fileserver_config; do not modify.',
  $template = 'puppet/master/fileserver.conf.erb'
){
  file { $name:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => template($template),
  }
}
