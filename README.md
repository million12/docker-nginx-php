# Nginx + PHP-FPM docker container

[![Build Status](https://jenkins.ozgo.info/jenkins/buildStatus/icon?job=ghp-million12-docker-nginx-php)](https://jenkins.ozgo.info/jenkins/view/GitHub%20Public%20Docker%20Images/job/ghp-million12-docker-nginx-php/)  
[![GitHub Open Issues](https://img.shields.io/github/issues/million12/docker-nginx-php.svg)](https://github.com/million12/docker-nginx-php/issues)
[![GitHub Stars](https://img.shields.io/github/stars/million12/docker-nginx-php.svg)](https://github.com/million12/docker-nginx-php)
[![GitHub Forks](https://img.shields.io/github/forks/million12/docker-nginx-php.svg)](https://github.com/million12/docker-nginx-php)  
[![Stars on Docker Hub](https://img.shields.io/docker/stars/million12/nginx-php.svg)](https://hub.docker.com/r/million12/nginx-php)
[![Pulls on Docker Hub](https://img.shields.io/docker/pulls/million12/nginx-php.svg)](https://hub.docker.com/r/million12/nginx-php)  
[![](https://images.microbadger.com/badges/version/million12/nginx-php.svg)](http://microbadger.com/images/million12/nginx-php)
[![](https://images.microbadger.com/badges/license/million12/nginx-php.svg)](http://microbadger.com/images/million12/nginx-php)  
[![](https://images.microbadger.com/badges/image/million12/nginx-php.svg)](http://microbadger.com/images/million12/nginx-php)

[![Docker build](https://dockeri.co/image/million12/nginx-php)](https://hub.docker.com/r/million12/nginx-php/)

Felling like supporting me in my projects use donate button. Thank You!  
[![](https://img.shields.io/badge/donate-PayPal-blue.svg)](https://www.paypal.me/POzgo)

This is a [million12/nginx-php](https://registry.hub.docker.com/u/million12/nginx-php/)
docker container with Nginx + PHP-FPM combo.

For different PHP versions, look up different branches of this repository.  
On Docker Hub you can find them under different tags:

* `million12/nginx-php:php74` - PHP 7.4 # built from `php74` branch
* `million12/nginx-php:php73` - PHP 7.3 # built from `php73` branch
* `million12/nginx-php:php70` - PHP 7.0 # built from `php70` branch
* `million12/nginx-php:php56` - PHP 5.6 # built from `php56` branch
* `million12/nginx-php:php55` - PHP 5.5 # built from `php55` branch


# Things included:

#### - Nginx with HTTP/2 support

This image is based on [million12/nginx](https://github.com/million12/docker-nginx).  
**Default vhost** is configured and served from `/data/www/default`. Add .php file 
to that location to have it executed with PHP.

#### - PHP-FPM

**PHP 7.4** is up & running for default vhost. As soon as .php file is requested, the request will be redirected to PHP upstream. See [/etc/nginx/conf.d/php-location.conf](container-files/etc/nginx/conf.d/php-location.conf).

File [/etc/nginx/fastcgi_params](container-files/etc/nginx/fastcgi_params) has improved configuration to avoid repeating same config options for each vhost. This config works well with most PHP applications (e.g. Symfony2, TYPO3, Wordpress, Drupal).

#### - PHP basic tuning
Custom PHP.ini directives are inside [/etc/php.d](container-files/etc/php.d/).

#### - Common dev tools for web app development
* git `2.14.1`
* Ruby `2.3`
* Bundler
* NodeJS
* NPM
* NPM packages like `gulp`, `grunt`, `bower`, `browser-sync`


# Directory structure inside image
```
/data/www # meant to contain web content
/data/www/default # root directory for the default vhost
/data/logs/ # Nginx, PHP logs
/data/tmp/php/ # PHP temp directories
```

# Error logging

PHP errors are forwarded to stderr (by leaving empty value for INI error_log setting) and captured by supervisor. You can see them easily via `docker logs [container]`. In addition, they are captured by parent Nginx worker and logged to `/data/logs/nginx-error.log'. PHP-FPM logs are available in `/data/logs/php-fpm*.log` files.

##### - pre-defined FastCGI cache for PHP backend

It's not used until specified in location {} context. In your vhost config you can add something like this:  
```
location ~ \.php$ {
    # Your standard directives...
    include               fastcgi_params;
    fastcgi_pass          php-upstream;

    # Use the configured cache (adjust fastcgi_cache_valid to your needs):
    fastcgi_cache         APPCACHE;
    fastcgi_cache_valid   60m;
}
```


# Usage

```
docker run -d -v /data --name=web-data busybox
docker run -d --volumes-from=web-data -p=80:80 --name=web million12/nginx-php
```

After that you can see the default vhost content (something like: '*default vhost created on [timestamp]*') when you open http://CONTAINER_IP:PORT/ in the browser.

You can replace `/data/www/default/index.html` with `index.php` and, for instance, phpinfo() to inspect installed PHP setup. You can do that using separate container which mounts /data volume (`docker run -ti --volumes-from=web-data --rm busybox`) and adding the file to the above location.


# Customise

There are several ways to customise this container, both in a runtime or when building new image on top of it:

* See [million12:nginx](https://github.com/million12/docker-nginx) for info regarding Nginx customisation, adding new vhosts etc.
* Override `/etc/nginx/fastcgi_params` if needed.
* Add custom PHP `*.ini` files to `/etc/php.d/`.
* Add own PHP-FPM .conf files to `/data/conf/php-fpm-www-*.conf` to modify PHP-FPM www pool.

## ENV variables

**NGINX_GENERATE_DEFAULT_VHOST**  
Default: `NGINX_GENERATE_DEFAULT_VHOST=false`  
Example: `NGINX_GENERATE_DEFAULT_VHOST=true`  
When set to `true`, dummy default (*catch-all*) Nginx vhost config file will be generated in `/etc/nginx/hosts.d/default.conf`. In addition, default index.php file will be created displaying results of `phpinfo()`. **Caveat**: this causes security leak because you expose detailed PHP configuration - remember to remove it on production!
Use it if you need it, for example to test that your Nginx is working correctly AND/OR if you don't create default vhost config for your app but you still want some dummy catch-all vhost.

**STATUS_PAGE_ALLOWED_IP**  
Default: `STATUS_PAGE_ALLOWED_IP=127.0.0.1`  
Example: `STATUS_PAGE_ALLOWED_IP=10.1.1.0/16`  
Configure ip address that would be allowed to see PHP-FPM status page on `/fpm_status` URL.

## Authors

Author: ryzy (<marcin@m12.io>)  
Author: pozgo (<linux@ozgo.info>)
