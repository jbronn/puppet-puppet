puppet
======

This module is for installing and configuring Puppet-related infrastructure.

Classes
-------

### `puppet`

Manages an existing puppet installation, can be used to change version of puppet.

### `puppet::agent`

Configures a Puppet agent.

### `puppet::board`

Configures [puppetboard](https://github.com/nedap/puppetboard), a dashboard for
[PuppetDB](https://docs.puppetlabs.com/puppetdb/); requires the `counsyl-python`
module.

### `puppet::config`

This class sets up the configuration directory structure and file for puppet.
By default, this will purge all unmanaged settings from `puppet.conf` unless
declared as a [`puppet_setting`](#puppet_setting) resource.  This behavior
can be disabled by setting the classes `purge` parameter to false.

#### `puppet::config::puppetlabs`

Creates and manages the root directory for open source Puppet Labs software,
`/etc/puppetlabs`.

#### `puppet::config::dir`

Creates and manages the configuration directory for open source Puppet,
`/etc/puppetlabs/puppet`.

#### `puppet::config::file`

Creates and manages the configuration file for open source Puppet,
`/etc/puppetlabs/puppet/puppet.conf`.  The *content* of this file is
not managed -- it merely makes sure it exists so it can be used by
the [`puppet_setting`](#puppet_setting) type.

For legacy version of Puppet (3.x), this class will also create a symlink to
this file from `/etc/puppet/puppet.conf`.

#### `puppet::config::r10k`

Creates and manages the configuration directory for r10k:
`/etc/puppetlabs/r10k`.

### `puppet::master`

Configures a Puppet master server.

### `puppet::r10k`

Installs r10k via Ruby Gems.

Defines
-------

### `puppet::hiera_config`

Generates a [hiera.yaml](http://docs.puppetlabs.com/hiera/1/configuring.html) configuration file.

### `puppet::master::fileserver_config`

Generates a [fileserver configuration file](http://docs.puppetlabs.com/guides/file_serving.html) for use by a Puppet master.

### `puppet::r10k::config_file`

Generates a [configuration file](https://github.com/puppetlabs/r10k/blob/master/doc/dynamic-environments/configuration.mkd) for r10k (`r10k.yaml`).

Types
-----

### `puppet_setting`

Manages open source puppet configuration settings in `/etc/puppetlabs/puppet/puppet.conf`.

License
-------

Apache License, Version 2.0

Contact
-------

Justin Bronn <justin@counsyl.com>

Support
-------

Please log tickets and issues at https://github.counsyl.com/dev/puppet-puppet
