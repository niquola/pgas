require 'rubygems'
gemfile = File.expand_path('../Gemfile', __FILE__)
begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'pg'
require 'active_record'
require 'pgas'
