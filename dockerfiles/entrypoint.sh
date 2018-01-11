#!/bin/sh

echo "127.0.0.1 local.host msk.local.host spb.local.host" >> /etc/hosts
echo "GEM_PATH=/usr/local/bundle/" | crontab -
(crontab -l ; echo "$(printenv | grep ^SC_)") | crontab -
cd tasks && whenever --update-crontab && cd ..

service cron start
padrino start -h 0.0.0.0 -a thin -e ${SC_ENV}
