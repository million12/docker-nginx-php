FROM million12/nginx:latest

ENV \
  NVM_DIR=/usr/local/nvm \
  NODE_VERSION=6.3.0 \
  STATUS_PAGE_ALLOWED_IP=127.0.0.1 \
  RUBY_VERSION=2.3 \
  GIT_VERSION=2.24.1 \
  PHP_MEMCACHED=3.1.5 \
  PHP_REDIS=5.1.1 \
  PHP_VERSION=73

# Add install scripts needed by the next RUN command
ADD container-files/config/install* /config/
ADD container-files/etc/yum.repos.d/* /etc/yum.repos.d/

RUN \
  yum update -y && \
  echo "Install some basic web-related tools..." && \
  yum install -y wget patch tar bzip2 unzip openssh-clients MariaDB-client && \
  echo "Install PHP 7.3 from Remi YUM repository..." && \
  rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
  yum install -y \
    php${PHP_VERSION}-php \
    php${PHP_VERSION}-php-bcmath \
    php${PHP_VERSION}-php-cli \
    php${PHP_VERSION}-php-common \
    php${PHP_VERSION}-php-devel \
    php${PHP_VERSION}-php-fpm \
    php${PHP_VERSION}-php-gd \
    php${PHP_VERSION}-php-gmp \
    php${PHP_VERSION}-php-intl \
    php${PHP_VERSION}-php-json \
    php${PHP_VERSION}-php-mbstring \
    php${PHP_VERSION}-php-mcrypt \
    php${PHP_VERSION}-php-mysqlnd \
    php${PHP_VERSION}-php-opcache \
    php${PHP_VERSION}-php-pdo \
    php${PHP_VERSION}-php-pear \
    php${PHP_VERSION}-php-process \
    php${PHP_VERSION}-php-pspell \
    php${PHP_VERSION}-php-xml \
    echo "install the following PECL packages:" && \
    php${PHP_VERSION}-php-pecl-imagick \
    php${PHP_VERSION}-php-pecl-mysql \
    php${PHP_VERSION}-php-pecl-uploadprogress \
    php${PHP_VERSION}-php-pecl-uuid \
    php${PHP_VERSION}-php-pecl-zip \
    || true && \
  echo "Set PATH so it includes newest PHP and its aliases..." && \
  ln -sfF /opt/remi/php${PHP_VERSION}/enable /etc/profile.d/php${PHP_VERSION}-paths.sh && \
  echo "The above will set PATH when container starts... but not when php is used on container build time." && \
  echo "Therefore create symlinks in /usr/local/bin for all PHP tools..." && \
  ln -sfF /opt/remi/php${PHP_VERSION}/root/usr/bin/{pear,pecl,phar,php,php-cgi,php-config,phpize} /usr/local/bin/. && \
  php --version && \
  echo "Move PHP config files from /etc/opt/remi/php${PHP_VERSION}/* to /etc/* " && \
  mv -f /etc/opt/remi/php${PHP_VERSION}/php.ini /etc/php.ini && ln -s /etc/php.ini /etc/opt/remi/php${PHP_VERSION}/php.ini && \
  rm -rf /etc/php.d && mv /etc/opt/remi/php${PHP_VERSION}/php.d /etc/. && ln -s /etc/php.d /etc/opt/remi/php${PHP_VERSION}/php.d && \
  echo 'PHP 7.3 installed.' && \
  echo "Install libs required to build some gem/npm packages (e.g. PhantomJS requires zlib-devel, libpng-devel)" && \
  yum install -y ImageMagick GraphicsMagick gcc gcc-c++ libffi-devel libpng-devel zlib-devel && \
  echo "Install common tools needed/useful during Web App development" && \
  echo "Install/compile other software (Git, NodeJS, Ruby)" && \
  source /config/install.sh && \
  echo "Install nvm and NodeJS/npm" && \
  export PROFILE=/etc/profile.d/nvm.sh && touch $PROFILE && \
  curl -sSL https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash && \
  source $NVM_DIR/nvm.sh && \
  nvm install $NODE_VERSION && \
  nvm alias default $NODE_VERSION && \
  nvm use default && \
  echo "Install common npm packages: grunt, gulp, bower, browser-sync" && \
  npm install -g gulp grunt-cli bower browser-sync && \
  echo "Disable SSH strict host key checking: needed to access git via SSH in non-interactive mode" && \
  echo -e "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
  echo "Install Memcached, Redis PECL extensions from the source. Versions available in yum repo have dependency on igbinary which causes PHP seg faults in some PHP apps (e.g. Flow/Neos)..." && \
  echo "Install PHP Memcached ext from the source..." && \
  yum install -y libmemcached-devel wget && \
  cd /tmp/ && \
  wget https://github.com/php-memcached-dev/php-memcached/archive/v${PHP_MEMCACHED}.tar.gz && \
  tar -zxf v${PHP_MEMCACHED}.tar.gz --no-same-owner && \
  cd php-memcached-${PHP_MEMCACHED} && \
  phpize && ./configure && make -j$(getconf _NPROCESSORS_ONLN) && make install && \
  rm -rf /tmp/php-memcached-${PHP_MEMCACHED} && rm -rf /tmp/v${PHP_MEMCACHED}.tar.gz && \
  echo "extension=memcached.so" > /etc/php.d/50-memcached.ini && \
  echo "Install PHP Redis ext from the source..." && \
  cd /tmp/ && \
  wget https://github.com/phpredis/phpredis/archive/${PHP_REDIS}.tar.gz && \
  tar -zxf ${PHP_REDIS}.tar.gz --no-same-owner && \
  cd phpredis-${PHP_REDIS} && \
  phpize && ./configure && make -j$(getconf _NPROCESSORS_ONLN) && make install && \
  rm -rf /tmp/phpredis-${PHP_REDIS} && rm -rf /tmp/${PHP_REDIS}.tar.gz && \
  echo "extension=redis.so" > /etc/php.d/50-redis.ini && \
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
  chown www /usr/local/bin/composer && composer --version && \
  echo "Clean YUM caches to minimise Docker image size... #" && \
  yum clean all && rm -rf /tmp/yum*

ADD container-files /

# Add NodeJS/npm to PATH (must be separate ENV instruction as we want to use $NVM_DIR)
ENV \
  NODE_PATH=$NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules \
  PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
