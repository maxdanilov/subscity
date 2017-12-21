#!/bin/sh

NAME="subscity-app"

cd "${0%/*}/../"
docker stop ${NAME} 2> /dev/null
