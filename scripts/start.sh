#!/bin/sh
set -e

cd "${0%/*}/../"

ENV=${1:-production}
NET="bridge"
IMAGE="subscity"

if [ "$ENV" = "production" ]; then
    IMAGE="maximdanilov/subscity:$(git rev-parse --abbrev-ref HEAD)"
    NET="host"
fi

echo "ENV=${ENV} IMAGE=${IMAGE} NET=${NET}"
ENV=${ENV} IMAGE=${IMAGE} NET=${NET} docker-compose up -d
