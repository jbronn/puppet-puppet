puppet
======

This module is for installing and configuring Puppet-related infrastructure.

Classes:

* `puppet`: Installs or upgrades Puppet itself.
* `puppet::agent`: Configures a Puppet agent.
* `puppet::master`: Configures a Puppet master server.
* `puppet::board`: Configures [puppetboard](https://github.com/nedap/puppetboard), a dashboard for [PuppetDB](https://docs.puppetlabs.com/puppetdb/); requires the `counsyl-python` module.

Defined types:

* `puppet::fileserver_config`: Generates a [fileserver configuration file](http://docs.puppetlabs.com/guides/file_serving.html) for use by a Puppet master.
* `puppet::hiera_config`: Generates a [hiera.yaml](http://docs.puppetlabs.com/hiera/1/configuring.html) configuration file.


License
-------

Apache License, Version 2.0

Contact
-------

Justin Bronn <justin@counsyl.com>

Support
-------

Please log tickets and issues at https://github.counsyl.com/dev/puppet-puppet
