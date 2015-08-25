puppet
======

This module is for installing and configuring Puppet-related infrastructure.

Classes:

* `puppet`: Installs or upgrades Puppet itself.
* `puppet::agent`: Configures a Puppet agent.
* `puppet::board`: Configures [puppetboard](https://github.com/nedap/puppetboard), a dashboard for [PuppetDB](https://docs.puppetlabs.com/puppetdb/); requires the `counsyl-python` module.
* `puppet::master`: Configures a Puppet master server.
* `puppet::r10k`: Installs r10k via Ruby Gems

Defined types:

* `puppet::hiera_config`: Generates a [hiera.yaml](http://docs.puppetlabs.com/hiera/1/configuring.html) configuration file.
* `puppet::master::fileserver_config`: Generates a [fileserver configuration file](http://docs.puppetlabs.com/guides/file_serving.html) for use by a Puppet master.
* `puppet::r10k::config`: Generates a [configuration file](https://github.com/puppetlabs/r10k/blob/master/doc/dynamic-environments/configuration.mkd) for r10k (`r10k.yaml`).

License
-------

Apache License, Version 2.0

Contact
-------

Justin Bronn <justin@counsyl.com>

Support
-------

Please log tickets and issues at https://github.counsyl.com/dev/puppet-puppet
