module Pgas
  autoload :DbManager, 'pgas/repository'
  autoload :DbManager, 'pgas/db_manager'

  class << self
    def connection_config
      require 'yaml'
      @connection_config ||= YAML::load(File.open(File.join(File.dirname(__FILE__),'..','config','connection.yml')))
    end
  end
end
