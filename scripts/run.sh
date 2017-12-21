#!/bin/sh
NAME="subscity-app"
PORT=3000
ENV=local

cd "${0%/*}/../"

docker stop ${NAME} 2> /dev/null
docker rm ${NAME} 2> /dev/null
docker run -d --name ${NAME} --env-file env/${ENV} --link mysql-subscity:mysql -p ${PORT}:${PORT} subscity
