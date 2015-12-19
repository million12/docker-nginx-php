#!/bin/sh

#
# Configure default vhost, if NGINX_GENERATE_DEFAULT_VHOST is set to TRUE
# See README for more info.
#

VHOSTS_DEFAULT_SOURCE_CONF="/config/init/vhost-default.conf"
VHOSTS_DEFAULT_TARGET_CONF="/etc/nginx/hosts.d/default.conf"

if [ "${NGINX_GENERATE_DEFAULT_VHOST^^}" = TRUE ]; then
  cat $VHOSTS_DEFAULT_SOURCE_CONF > $VHOSTS_DEFAULT_TARGET_CONF
  mkdir -p /data/www/default
  echo "default vhost # created on $(date)" > /data/www/default/index.php
  echo "<?php phpinfo();" >> /data/www/default/index.php
  echo "Nginx: default *catch-all* vhost with PHP support generated."; echo
fi
