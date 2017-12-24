#!/bin/sh
set -e

cd "${0%/*}/../"
lessc --clean-css public/less/design.less public/stylesheets/design.css
uglifyjs public/javascripts/default.js --compress --mangle --output public/javascripts/default.min.js
docker build . -t subscity
