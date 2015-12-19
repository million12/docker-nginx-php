#!/bin/sh

#
# Configure PHP
#

# Because PHP 7 installed from remi Yum repositories is installed
# in non-standard PATHs, we need to configure it, which does the following script
# See Dockerfile - the following script is symlinked to /opt/remi/php70/enable.
#
# Note: wrap in set +-e as there are some unbound variables and our scripts are strict about it.
set +e
source /etc/profile.d/php70-paths.sh
set -e
