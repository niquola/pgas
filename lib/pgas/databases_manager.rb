require 'pgas/repository'
module Pgas
  class DatabasesManager

    class Anonim < ActiveRecord::Base
    end

    attr :connection_config
    attr :connection

    def initialize(connection_config)
      @connection_config = connection_config
      Anonim.establish_connection(connection_config)
      @connection = Anonim.connection
    end

    def list
      connection.select_values('SELECT datname FROM pg_database')
    end

    #create database and return connection information
    def create(database_name, comment = nil)
      #database_name = generate_name(prefix)
      Database.new(connection, database_name, comment).create
      get_connection(database_name)
    end

    def drop(database_name, force = false)
      Database.new(connection, database_name).drop(force)
    end

    def exists?(database_name)
      Database.new(connection, database_name).exists?
    end

    def get_connection(database_name)
      database = Database.new(connection, database_name)
      fail "Database #{database_name} does not exist" unless database.exists?
      connection_config.merge('database' => database_name)
    end

    def clone(template_database_name, clone_name)
      template = Database.new(connection, template_database_name)
      clone = template.clone(clone_name)
      get_connection(clone.database_name)
    end

    def list_dumps
    end

    def dump(database_name, dump_id = nil)
    end

    def restore(dump_id, database_name)
    end

    private

    def generate_name(prefix)
      now = Time.now.strftime('%Y%m%d%H%M%S')
      "#{prefix}_#{now}"
    end
  end
end
