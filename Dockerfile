FROM million12/nginx:latest
MAINTAINER Marcin Ryzycki <marcin@m12.io>

RUN \
  yum update -y --disablerepo=updates || yum update -y && \
  yum install -y yum-utils && \
  
  `# Install PHP 7.0 from packages available in remi-test` \
  rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
  yum-config-manager -q --enable remi && \
  yum-config-manager -q --enable remi-test && \
  yum install -y php70 php70-runtime php70-php-bcmath php70-php-cli php70-php-common php70-php-fpm \
                  php70-php-gd php70-php-json php70-php-mbstring php70-php-mcrypt php70-php-mysqlnd \
                  php70-php-opcache php70-php-pdo php70-php-process php70-php-pspell \
                  php70-php-pecl-uuid php70-php-xml php70-php-zip && \
  `# Set env variables, PATH etc, also put it in /etc/profile + make a php alias to php70, so the php command is present no matter if /etc/profile has been loaded or not...` \
  source /opt/remi/php70/enable && ln -s /opt/remi/php70/enable /etc/profile.d/php70.sh && ln -s /usr/bin/php70 /usr/bin/php && \
  
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
