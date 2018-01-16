#!/bin/bash
set -e

# initial cert generation:
# letsencrypt certonly --webroot -w /var/www/subscity/public/ \
# -d subscity.ru -d www.subscity.ru -d msk.subscity.ru -d spb.subscity.ru

cd "${0%/*}/../"
docker-compose stop nginx
letsencrypt renew --standalone
cp -L /etc/letsencrypt/live/subscity.ru/*.pem dockerfiles/certs/production/
docker-compose start nginx
