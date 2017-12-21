#!/bin/sh

cd "${0%/*}/../"
docker build . -t subscity
