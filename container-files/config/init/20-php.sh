#!/bin/sh

#
# Configure PHP
#

# Because PHP 7 installed from remi Yum repositories is installed
# in non-standard PATHs, we need to configure it, which does the following script
# See Dockerfile - the following script is symlinked to /opt/remi/php70/enable.
#
# Note: define MANPATH so bash doesn't complain about unbound MANPATH variable from there
export MANPATH=""
source /etc/profile.d/php70-paths.sh
