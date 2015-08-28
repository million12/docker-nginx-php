# Nginx + PHP-FPM docker container
[![Circle CI](https://circleci.com/gh/million12/docker-nginx-php/tree/master.svg?style=svg)](https://circleci.com/gh/million12/docker-nginx-php/tree/master)

This is a [million12/nginx-php](https://registry.hub.docker.com/u/million12/nginx-php/) docker container with Nginx + PHP-FPM combo. 

For different PHP versions, look up different branches of this repository. On Docker Hub you can find them under different tags:    
* `million12/nginx-php:latest` - PHP 5.6 (master branch)
* `million12/nginx-php:php-55` - PHP 5.5 ([php-55](https://github.com/million12/docker-nginx-php/tree/php-55) branch)
* `million12/nginx-php:php-70` - PHP 7.0-dev aka PHPNG ([php-70](https://github.com/million12/docker-nginx-php/tree/php-70) branch)


#### Things included:

#### Nginx

This image is based on [million12/nginx](https://github.com/million12/docker-nginx) - go there for more details.  
**Default vhost** is configured and served from `/data/www/default`. Add .php file to that location to have it executed with PHP.

#### - PHP-FPM

**PHP 5.6** is up & running for default vhost. As soon as .php file is requested, the request will be redirected to PHP upstream. See [/etc/nginx/conf.d/php-location.conf](container-files/etc/nginx/conf.d/php-location.conf).

File [/etc/nginx/fastcgi_params](container-files/etc/nginx/fastcgi_params) has improved configuration to avoid repeating same config options for each vhost. This config works well with most PHP applications (e.g. Symfony2, TYPO3, Wordpress, Drupal).

Custom PHP.ini directives are inside [/etc/php.d](container-files/etc/php.d/).

#### Directory structure
```
/data/www # meant to contain web content
/data/www/default # root directory for the default vhost
/data/logs/ # Nginx, PHP logs
/data/tmp/php/ # PHP temp directories
```

#### Error logging

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

#### Common dev tools for web app development

* Ruby 2.0, Bundler
* NodeJS and NPM
* NPM packages like gulp, grunt, bower, browser-sync

## Usage

```
docker run -d -v /data --name=web-data busybox
docker run -d --volumes-from=web-data -p=80:80 --name=web million12/nginx-php
```

After that you can see the default vhost content (something like: '*default vhost created on [timestamp]*') when you open http://CONTAINER_IP:PORT/ in the browser.

You can replace `/data/www/default/index.html` with `index.php` and, for instance, phpinfo() to inspect installed PHP setup. You can do that using separate container which mounts /data volume (`docker run -ti --volumes-from=web-data --rm busybox`) and adding the file to the above location.


## Customise

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

---

**Sponsored by** [Typostrap.io - the new prototyping tool](http://typostrap.io/) for building highly-interactive prototypes of your website or web app. Built on top of TYPO3 Neos CMS and Zurb Foundation framework.
