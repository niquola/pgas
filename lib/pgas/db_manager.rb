require 'pgas/repository'
module Pgas
  class DbAlreadyExistsError < StandardError; end
  class DbManager
    def initialize(connection_config)
      @connection_config = connection_config
    end

    def create_db(name,opts={})
      raise DbAlreadyExistsError if db_exists?(name)
      template = opts[:template]
      if template
        try_load(template) unless db_exists?(template)
        template = "WITH TEMPLATE #{template}"
      end
      res = conn.exec("CREATE DATABASE #{name} #{template};")
      if  res.result_status
        @connection_config.merge('database' => name)
      else
        raise res.result_error_message
      end
    end

    def drop_db(name,opts={})
      return unless db_exists?(name)
      res = conn.exec("DROP DATABASE #{name};")
      if  res.result_status
        return true
      else
        raise res.result_error_message
      end
    end

    private

    def conn(name = 'postgres')
      cfg = @connection_config.merge('dbname'=>name)
      conn = PG.connect(cfg)
      if block_given?
        yield conn
        conn.close
      else
        conn
      end
    end

    def db_exists?(name)
      res = nil
      conn do |c|
        res = c.exec "select 1 from pg_database where datname = '#{name}'"
      end
      res.num_tuples > 0
    end

    def try_load(name)
      Pgas::Repository.load(name)
    end

    def pg_command(command)
      config = @connection_config
      str = command.dup
      str << " -h #{config['host']}" if config['host']
      str << " -p #{config['port']}" if config['port']
      str << " -U #{config['username']}" if config['username']
      str << "env PGPASSWORD=#{config['password']} #{str} -w" if config['password']
      str
    end
  end
end
