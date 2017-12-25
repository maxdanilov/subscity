#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

Encoding.default_external = Encoding::UTF_8

require File.expand_path("../config/boot.rb", __FILE__)

run Padrino.application
