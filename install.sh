#!/bin/bash

# Subscity setup and config script (requires human interaction)
# best suits clean Ubuntu 14.04 LTS

RUBY_VERSION="2.3.0"
INSTALL_DIR="/root/subscity/"
INSTALL_DIR_ROOT="/var/www/"
INSTALL_DIR="${INSTALL_DIR_ROOT}subscity/"

sudo usermod -a -G www-data root
#installing extra packages

sudo apt-get update
sudo apt-get upgrade

# choose apropriate TZ
sudo dpkg-reconfigure tzdata

sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install $RUBY_VERSION
rvm use $RUBY_VERSION --default

sudo apt-get install realpath unzip git mysql-server libmysqlclient-dev
sudo mysql_secure_installation

sudo apt-get install phpmyadmin
sudo php5enmod mcrypt
# change phpmyadmin URL
sed -i 's/Alias \/phpmyadmin/Alias \/pad4/g' /etc/phpmyadmin/apache.conf
sudo echo "" > /var/www/html/index.html
# enabling apache modules
a2enmod proxy proxy_http headers deflate mime expires ssl rewrite

cd ${INSTALL_DIR_ROOT}
git clone https://github.com/maxdanilov/subscity.git

# copying apache config and enabling site
cp ${INSTALL_DIR}/config/subscity.conf /etc/apache2/sites-available/
cp ${INSTALL_DIR}/config/subscity-ssl.conf /etc/apache2/sites-available/
a2ensite subscity subscity-ssl
service apache2 restart

wget http://mysqltuner.pl/ -O ${INSTALL_DIR_ROOT}mysqltuner.pl

# in pad create a 'subscity' db
# import mysql backup into 'subscity' db

# gems and dependencies
sudo apt-get install mailutils mutt
sudo apt-get install libgmp3-dev
sudo apt-get install graphicsmagick-libmagick-dev-compat
sudo apt-get install libmagickcore-dev
sudo apt-get install libmagickwand-dev imagemagick

sudo apt-get install bundler
gem install whenever
gem install bundle

# subscity itself
cd ${INSTALL_DIR}
bundle install
config.sh

# setting cron to run & check padrino

crontab -l | sed ":${INSTALL_DIR}monitor.sh:d" | crontab -
crontab -l | sed ":MAILTO:d" | crontab -
(crontab -l ; echo "* * * * * /bin/bash -l -c \"${INSTALL_DIR}monitor.sh\"") | crontab -
(echo 'MAILTO=""' ; crontab -l) | crontab -

