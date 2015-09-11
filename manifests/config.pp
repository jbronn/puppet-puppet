# == Class: puppet::config
#
# Creates the directory structure and file for configuring open source puppet.
#
# === Parameters
#
# [*purge*]
#  Whether or not to purge unmanaged `puppet_setting` resources, defaults to true.
#
class puppet::config(
  $purge = true,
) {
  include puppet::config::file

  resources { 'puppet_setting':
    purge => $purge,
  }
}
