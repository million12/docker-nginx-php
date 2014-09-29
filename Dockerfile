FROM million12/nginx:latest
MAINTAINER Marcin Ryzycki <marcin@m12.io>

RUN \
  yum install -y yum-utils && \
  
  rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
  yum-config-manager -q --enable remi && \
  yum-config-manager -q --enable remi-php55 && \

  yum install -y php-fpm php-bcmath php-cli php-gd php-intl php-mbstring \
                  php-mcrypt php-mysql php-opcache php-pdo && \
  yum install -y --disablerepo=epel php-pecl-redis php-pecl-yaml && \
  yum clean all && \

  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ADD container-files /
