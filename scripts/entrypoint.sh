#!/bin/sh

echo "GEM_PATH=/usr/local/bundle/" | crontab -
(crontab -l ; echo "$(printenv | grep ^SC_)") | crontab -
cd tasks && whenever --update-crontab && cd ..

service cron start
padrino start -h 0.0.0.0 -a thin -e ${SC_ENV}
