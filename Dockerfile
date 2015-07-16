FROM million12/nginx:latest
MAINTAINER Marcin Ryzycki <marcin@m12.io>

ADD container-files/config/install* /config/

RUN \
  rpm --rebuilddb && yum update -y && \
  `# Install yum-utils (provides yum-config-manager) + some basic web-related tools...` \
  yum install -y yum-utils wget patch mysql tar bzip2 unzip openssh-clients && \

  `# Install PHP 5.6` \
  rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
  yum-config-manager -q --enable remi && \
  yum-config-manager -q --enable remi-php56 && \
  yum install -y php-fpm php-bcmath php-cli php-gd php-intl php-mbstring \
                  php-pecl-imagick php-mcrypt php-mysql php-opcache php-pdo && \
  yum install -y --disablerepo=epel php-pecl-redis php-pecl-yaml && \

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
