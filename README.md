# Nginx+PHP-FPM docker container

This is a [million12/nginx-php](https://registry.hub.docker.com/u/million12/nginx-php/) docker container with Nginx+PHP-FPM combo.

Things included:

##### - PHP-FPM configured

PHP is up&running for default vhost. As soon as .php file is requested, the request will be send to PHP upstream. See [/etc/nginx/conf.d/php-location.conf](etc/nginx/conf.d/php-location.conf).

File [/etc/nginx/fastcgi_params](etc/nginx/fastcgi_params) has improved configuration to avoid repeating same options in each vhost. It should work well with most PHP applications (e.g. TYPO3, Wordpress, Drupal).

Custom PHP.ini directives are inside [/etc/php.d/zz-php.ini](etc/php.d/zz-php.ini).

##### - directory structure
```
/data/www # meant to contain web content
/data/www/default # default vhost directory
```

##### - default vhost

Default vhost is configured and served from `/data/www/default`. Add .php file to that location to have it executed with PHP.

##### - error logging

This is probably best approach if you'd like to source your logs from outside the container (e.g. via `docker logs` or CoreOS `journald') and you don't want to worry about logging and log management inside your container.


## Usage

```
docker run -d -v /data --name=web-data busybox
docker run -d --volumes-from=web-data -p=80:80 million12/nginx-php
```

After that you can see the default vhost content (something like: '*default vhost created on [timestamp]*') when you open http://CONTAINER_IP:PORT/ in the browser.

You can replace `/data/www/default/index.html` with `index.php` and, for instance, phpinfo() to inspect installed PHP modules. You can do that using separate container which mounts /data volume (`docker run -ti --volumes-from=web-data --rm busybox`).


## Customise

There are few ways to customise this container, both in a runtime or when building new image on top of it:

* See [million12:nginx](https://github.com/million12/docker-nginx) for Nginx customisation, adding new vhosts etc.
* Override `/etc/nginx/fastcgi_params` if needed
* Add custom PHP `*.ini` files to `/etc/php.d/`
* Add `include = /data/conf/php-fpm-www-*.conf` to modify PHP-FPM www pool.


## Authors

Author: ryzy (<marcin@m12.io>)  
Author: pozgo (<linux@ozgo.info>)
