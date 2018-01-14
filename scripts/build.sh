#!/bin/sh
set -e

cd "${0%/*}/../"
docker build . -t subscity $@
