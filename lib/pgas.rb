module Pgas
  autoload :DatabasesManager, 'pgas/databases_manager'
  autoload :Database, 'pgas/database'

  class << self
    def connection_config
      require 'yaml'
      @connection_config ||= YAML::load(File.open(File.join(File.dirname(__FILE__),'..','config','connection.yml')))
    end
  end
end
