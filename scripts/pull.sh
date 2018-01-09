#!/bin/bash
set -e

cd "${0%/*}/../"
docker pull maximdanilov/subscity:$(git rev-parse --abbrev-ref HEAD)-latest
docker pull nginx:latest
docker pull mysql:5.7.20
