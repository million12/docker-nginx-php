#!/bin/bash

echo "=============================================================="
echo "Installing Ruby ${RUBY_VERSION}...                            "
echo "=============================================================="

curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
curl -L get.rvm.io | bash -s stable
echo 'source /etc/profile.d/rvm.sh' >> /etc/profile
/usr/bin/bash -l -c "rvm reload"
/usr/bin/bash -l -c "rvm requirements run"
/usr/bin/bash -l -c "rvm install ${RUBY_VERSION}"
/usr/bin/bash -l -c "rvm use ${RUBY_VERSION} --default"
/usr/bin/bash -l -c "ruby --version"
echo 'gem: --no-document' > /etc/gemrc
/usr/bin/bash -l -c "gem update --system"
/usr/bin/bash -l -c "gem install bundler"
echo && echo "Ruby installed." && echo
