#!/bin/sh

#
# This script will be placed in /config/init/ and run when container starts.
# It creates (if they're not exist yet) necessary Nginx directories
# @see /etc/nginx/addon.d/fastcgi-cache.example
#

set -e

mkdir -p /data/tmp/php/uploads
mkdir -p /data/tmp/php/sessions
mkdir -p /data/tmp/nginx/fastcgi_cache
mkdir -p /data/tmp/nginx/fastcgi_cache_tmp
chown -R www:www /data/tmp/php /data/tmp/nginx/fastcgi_cache*
