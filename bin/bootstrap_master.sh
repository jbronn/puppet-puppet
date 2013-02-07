#!/usr/bin/env bash
#
# This script must be run with root privileges; you will need this module
# (`counsy-puppet`) in addition to counsyl-sys, counsyl-ruby, and counsyl-apache
# in order to successfully run this script.  These additional modules
# must be in the parent directory of this module.
MODULEPATH="../.."
TMPDIR="/tmp/puppet"
VARDIR="/var/lib/puppet"

# Create Puppet system group and user, and then apply the `puppet::master`
# manifests -- which creates the Puppet master, using temporary directories
# to hold the cruft that Puppet creates on first boot preventing it from
# clashing with our Puppet master's own configuration files/directories.
mkdir -p $TMPDIR && \
puppet apply --verbose -e "include puppet::master" \
    --modulepath=$MODULEPATH \
    --confdir=$TMPDIR/etc \
    --vardir=$TMPDIR/var && \
rm -fr $TMPDIR && \
chown -R puppet:puppet $VARDIR
