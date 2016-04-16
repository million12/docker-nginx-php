#!/usr/bin/env bash

#
# Make sure nvm is initialised on container start
# or when run directly using
# `docker run -ti million12/nginx-php nvm`
#
# The 'set -u' is set globally in parent million12/centos-supervisor,
# but nvm.sh doesn't work with it, throwing errors. Need to disable it temporarily.
set +u
source $NVM_DIR/nvm.sh
set -u
