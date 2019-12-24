#!/bin/bash
set -e

yum list installed | cut -f 1 -d " " | uniq | sort > /tmp/yum-pre
yum install -y automake autoconf libtoolize openssl-devel curl-devel expat-devel \
               gettext-devel perl-ExtUtils-MakeMaker

source /config/install-git.sh

yum list installed | cut -f 1 -d " " | uniq | sort > /tmp/yum-post
diff /tmp/yum-pre /tmp/yum-post | grep "^>" | cut -f 2 -d ' ' | xargs yum erase -y

source /config/install-ruby.sh