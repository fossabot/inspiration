# Defines our constants
RACK_ENV ||= ENV['RACK_ENV'] ||= 'development'  unless defined?(RACK_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, RACK_ENV)

require 'json'
require 'open-uri'
require 'rss'
require 'set'

logging_to_stdout = { :log_level => :devel, :stream => :stdout, :format_datetime => ' ', :log_static => true }
Padrino::Logger::Config[:development].merge!(logging_to_stdout)
Padrino::Logger::Config[:production].merge!(logging_to_stdout)

## Configure your I18n
I18n.enforce_available_locales = false
I18n.default_locale = :en

##
# Add your before (RE)load hooks here
#
Padrino.before_load do
end

##
# Add your after (RE)load hooks here
#
Padrino.after_load do
end

Padrino.load!
