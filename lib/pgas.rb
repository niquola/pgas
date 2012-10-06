require 'pg'
require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'
module Pgas
  autoload :Database, 'pgas/database'
  autoload :Role, 'pgas/role'
  autoload :PgStatActivity, 'pgas/pg_stat_activity'
  autoload :RestApi, 'pgas/rest_api'

  class << self
    def connection_config
      require 'yaml'
      @connection_config ||= YAML::load(File.open(File.join(File.dirname(__FILE__),'..','config','internal_connection.yml')))
    end

    def public_connection_config
      require 'yaml'
      @connection_config ||= YAML::load(File.open(File.join(File.dirname(__FILE__),'..','config','public_connection.yml')))
    end

    def connection
      @connection ||= ActiveRecord::Base.postgresql_connection(self.connection_config)
    end
  end
end
