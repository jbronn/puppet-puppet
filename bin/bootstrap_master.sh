#!/usr/bin/env bash
#
# This script must be run with root privileges; you will need this module
# (`counsy-puppet`) in addition to counsyl-sys, counsyl-ruby, and counsyl-apache
# in order to successfully run this script.  This script assumes these modules
# are in the same path as this one.
MODULEPATH="$( cd "$( dirname "$0" )/../.." && pwd )"
TMPDIR="/tmp/puppet"
VARDIR="/var/lib/puppet"

# Apply the `puppet::master` module, which creates the Puppet master
# using temporary directories to hold the cruft that Puppet creates on
# first run.
mkdir -p $TMPDIR && \
puppet apply --verbose -e "include puppet::master" \
    --modulepath=$MODULEPATH \
    --confdir=$TMPDIR/etc \
    --vardir=$TMPDIR/var && \
rm -fr $TMPDIR && \
chown -R puppet:puppet $VARDIR
