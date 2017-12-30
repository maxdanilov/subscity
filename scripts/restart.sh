#!/bin/sh
set -e

cd "${0%/*}/../"

./scripts/stop.sh
./scripts/start.sh "${1}"
