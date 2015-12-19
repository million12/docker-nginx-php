FROM million12/nginx:latest
MAINTAINER Marcin Ryzycki <marcin@m12.io>

# Add install scripts needed by the next RUN command
ADD container-files/config/install* /config/

RUN \
  rpm --rebuilddb && yum update -y && \
  `# Install yum-utils (provides yum-config-manager) + some basic web-related tools...` \
  yum install -y yum-utils wget patch mysql tar bzip2 unzip openssh-clients rsync && \

  `# Install PHP 7.0 from Remi YUM repository...` \
  rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \

  yum install -y \
    php70-php \
    php70-php-bcmath \
    php70-php-cli \
    php70-php-common \
    php70-php-devel \
    php70-php-fpm \
    php70-php-gd \
    php70-php-gmp \
    php70-php-horde-horde-lz4 \
    php70-php-intl \
    php70-php-json \
    php70-php-mbstring \
    php70-php-mcrypt \
    php70-php-mysqlnd \
    php70-php-opcache \
    php70-php-pdo \
    php70-php-pear \
    php70-php-process \
    php70-php-pspell \

    `# Also install the following PECL packages:` \
    php70-php-pecl-http \
    php70-php-pecl-imagick \
    php70-php-pecl-memcached \
    php70-php-pecl-uploadprogress \
    php70-php-pecl-uuid \
    php70-php-pecl-yaml \
    php70-php-pecl-zip \

  `# Set env variables, PATH etc, also put it in /etc/profile + make a php alias to php70, so the php command is present no matter if /etc/profile has been loaded or not...` \
  source /opt/remi/php70/enable && ln -s /opt/remi/php70/enable /etc/profile.d/php70-paths.sh && \

  `# Install libs required to build some gem/npm packages (e.g. PhantomJS requires zlib-devel, libpng-devel)` \
  yum install -y ImageMagick GraphicsMagick gcc gcc-c++ libffi-devel libpng-devel zlib-devel && \

  `# Install common tools needed/useful during Web App development` \

  `# Install Ruby 2` \
  yum install -y ruby ruby-devel && \

  `# Install/compile other software (Git, NodeJS)` \
  source /config/install.sh && \

  yum clean all && rm -rf /tmp/yum* && \

  `# Install common npm packages: grunt, gulp, bower, browser-sync` \
  npm install -g gulp grunt-cli bower browser-sync && \

  `# Update RubyGems, install Bundler` \
  echo 'gem: --no-document' > /etc/gemrc && gem update --system && gem install bundler && \

  `# Disable SSH strict host key checking: needed to access git via SSH in non-interactive mode` \
  echo -e "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \

  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
  chown www /usr/local/bin/composer

ADD container-files /

ENV STATUS_PAGE_ALLOWED_IP=127.0.0.1
