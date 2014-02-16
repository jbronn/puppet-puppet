# == Class: puppet::openbsd
#
# This class is used to bootstrap a OpenBSD puppet installation to remove
# default configuration files and fix the package provider for the platform.
# This class should be included only on the first puppet run on an OpenBSD node,
# and is not included by default in the `sys::openbsd` class for this reason.
#
class puppet::openbsd {
  # Customized OpenBSD package provider, fixes Puppet bug #8436, and #9651:
  #  http://projects.puppetlabs.com/issues/8436
  #  http://projects.puppetlabs.com/issues/9651
  # The released version Puppet's OpenBSD provider has not worked in
  # ages, so this will still be necessary for versions prior to 3.5.0.
  if versioncmp($::puppetversion, '3.5.0') < 0 {
    file { "${::rubysitedir}/puppet/provider/package/openbsd.rb":
      ensure  => file,
      owner   => 'root',
      group   => 'wheel',
      mode    => '0644',
      alias   => 'openbsd-package-provider-fix',
      source  => 'puppet:///modules/puppet/provider/openbsd.rb',
    }
  }
}
