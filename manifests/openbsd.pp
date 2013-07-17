# == Class: puppet::openbsd
#
# This class is used to bootstrap a OpenBSD puppet installation to remove
# default configuration files and fix the package provider for the platform.
# This class should be included only on the first puppet run on an OpenBSD node,
# and is not included by default in the `sys::openbsd` class for this reason.
#
class puppet::openbsd {
  # Customized OpenBSD package provider, fixes Puppet bug #8435,
  # #8436, and #9651:
  #  http://projects.puppetlabs.com/issues/8435
  #  http://projects.puppetlabs.com/issues/8436
  #  http://projects.puppetlabs.com/issues/9651
  # The released version Puppet's OpenBSD provider has not worked in
  # ages, so this will still be necessary for the forseeable future.
  if versioncmp($::puppetversion, '3.3.0') < 0 {
    file { "${::rubysitedir}/puppet/provider/package/openbsd.rb":
      ensure  => file,
      owner   => 'root',
      group   => 'wheel',
      mode    => '0644',
      alias   => 'openbsd-package-provider-fix',
      source  => 'puppet:///modules/puppet/provider/openbsd.rb',
    }
  }

  # These default files included in OpenBSD's puppet package
  # have strange default entries (like allowing collections
  # to a 'madstop.com' domain).  Let's just get rid of them all,
  # except for a blank `puppet.conf`.
  file { '/etc/puppet/puppet.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'wheel',
    mode    => '0644',
    content => '',
  }

  file { '/etc/puppet/fileserver.conf':
    ensure => absent,
  }

  file { '/etc/puppet/namespaceauth.conf':
    ensure => absent,
  }

  file { '/etc/puppet/tagmail.conf':
    ensure => absent,
  }

  file { '/etc/puppet/ssl/ca':
    ensure  => absent,
    purge   => true,
    recurse => true,
  }
}
