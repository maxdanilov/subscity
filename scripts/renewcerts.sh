#!/bin/bash
set -e

cd "${0%/*}/../"
./letsencrypt-auto renew
cp -L /etc/letsencrypt/live/subscity.ru/*.pem dockerfiles/certs/production/
docker-compose restart nginx
