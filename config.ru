require 'rubygems'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'lib')
require 'pgas'

use Rack::ShowExceptions
run Pgas::RestApi.new
