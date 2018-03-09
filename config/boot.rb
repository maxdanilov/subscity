# Defines our constants
RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined?(RACK_ENV)
PADRINO_ROOT = File.expand_path('..', __dir__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, RACK_ENV)

Padrino.before_load do
  require_relative '../app/helpers/cache'
  puts 'clearing cache...'
  FileCache.expire
end

Padrino.after_load do
end

Padrino.load!
