# == Class: puppet::master::redhat
#
# Experimental. Configures the Puppet Master on RedHat platforms.
#
class puppet::master::redhat {
  # Set the firewall on RedHat platforms to allow 8140.
  file { '/etc/sysconfig/iptables':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => '*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -p tcp --dport 8140 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
',
  }

  exec { '/sbin/service iptables restart':
    refreshonly => true,
    subscribe   => File['/etc/sysconfig/iptables'],
  }

  # Apache is not allowed to listen to 8140 unless
  # SELinux is disabled.  I'm sure there's a way to
  # craft a policy for this, but I don't know how.
  sys::redhat::selinux { 'permissive': }
}
