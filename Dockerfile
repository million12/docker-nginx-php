FROM million12/nginx:latest
MAINTAINER Marcin Ryzycki <marcin@m12.io>

RUN \
  yum install -y yum-utils && \
  
  `# Install PHP 5.6` \
  rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
  yum-config-manager -q --enable remi && \
  yum-config-manager -q --enable remi-php56 && \
  yum install -y php-fpm php-bcmath php-cli php-gd php-intl php-mbstring \
                  php-mcrypt php-mysql php-opcache php-pdo && \
  yum install -y --disablerepo=epel php-pecl-redis php-pecl-yaml && \
  
  `# Install common tools needed/useful during Web App development` \
  yum install -y git-core patch mysql tar bzip2 unzip wget GraphicsMagick && \
  `# Install Ruby 2 and NodeJS + some libs required by npm packages (PhantomJS requires zlib-devel, libpng-devel)` \
  yum install -y ruby ruby-devel nodejs npm zlib-devel libpng-devel && \
  
  yum clean all && \
  
  `# Update npm and install common npm packages: grunt, gulp, bower, browser-sync` \
  npm update -g npm && \
  npm install -g gulp grunt-cli bower browser-sync && \
  
  `# Update RubyGems, install Bundler` \
  echo 'gem: --no-document' > /etc/gemrc && gem update --system && gem install bundler && \
  
  `# Disable SSH strict host key checking: needed to access git via SSH in non-interactive mode` \
  echo -e "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \

  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
  chown www /usr/local/bin/composer

ADD container-files /

ENV STATUS_PAGE_ALLOWED_IP=127.0.0.1
