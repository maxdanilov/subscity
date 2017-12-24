#!/bin/sh
NAME="subscity-app"
PORT=3000
ENV="${1:-local}"

cd "${0%/*}/../"

if [ "${ENV}" != "travis" ]; then
    docker stop ${NAME} 2> /dev/null
    docker rm ${NAME} 2> /dev/null
    NETWORK_MODE=""
else
    NETWORK_MODE="--net=host"
fi

docker run -d \
    --name ${NAME} \
    --env-file env/${ENV} \
    --mount type=bind,source="$(pwd)",target=/subscity \
    -p ${PORT}:${PORT} \
    ${NETWORK_MODE} \
    subscity
