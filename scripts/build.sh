#!/bin/sh
set -e

cd "${0%/*}/../"
lessc --clean-css public/less/design.less public/stylesheets/design.css
docker build . -t subscity
