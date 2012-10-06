module Pgas
  class Database
    attr_reader :name
    attr_reader :master_connection
    attr_reader :comment

    def self.master_connection
      @master_connection ||= Pgas.connection
    end

    def master_connection
      self.class.master_connection
    end

    def self.all
      self.master_connection.select_values('SELECT datname FROM pg_database').sort.map do |name|
        self.new(name)
      end
    end

    def comment
      @comment ||= get_comment
    end

    def get_comment
    end

    #override equality
    def ==(other)
      other.name == name
    end

    def initialize(name, comment = nil)
      @name = name
      @comment = comment
    end

    def create
      #FIXME: sanitize all params
      master_connection.execute "CREATE DATABASE #{name}"
      master_connection.execute "COMMENT ON DATABASE #{name} IS '#{comment}'" if comment
    end

    def tables
      connection.select_rows <<-SQL
	select * from pg_catalog.pg_tables
	where schemaname not in ('pg_catalog','information_schema') order by  schemaname, tablename
	SQL
    end

    def size
      master_connection.select_value "select pg_size_pretty(pg_database_size('#{self.name}'))"
    end

    def drop(force = false)
      fail "Database #{name} not exists?" unless self.exists?
      fail "Database #{name} in use" if not force and  self.has_connections?
      self.close_connections if force
      master_connection.execute %(DROP DATABASE "#{name}";)
    end

    def exists?
      master_connection.select_value("select 1 from pg_database where datname = '#{name}'") == '1'
    end

    def activity_stat
      master_connection.select_all <<-SQL
        SELECT *
        FROM pg_stat_activity
        WHERE datname = '#{name}'
        AND procpid <> pg_backend_pid()
      SQL
    end

    def connected_users
      self.activity_stat.map{|a| a["usename"]}.uniq
    end

    def has_connections?
      self.connected_users.length > 0
    end

    def prevent_connections
      users = ['PUBLIC'] + self.connected_users
      master_connection.execute <<-SQL
        REVOKE CONNECT
        ON DATABASE #{name}
        FROM #{users.join(', ')}
        SQL
    end

    def comment
      @comment ||= master_connection.select_value "SELECT description FROM pg_shdescription WHERE objoid = (SELECT oid FROM pg_database WHERE datname = '#{self.name}')"
    end

    def clone(clone_name, comment = nil)
      fail "Template database #{name} is being accessed" if self.has_connections?
      master_connection.execute "CREATE DATABASE #{clone_name} WITH TEMPLATE #{name}"
      master_connection.execute "COMMENT ON DATABASE #{clone_name} IS '#{comment}'" if comment

      Database.new(clone_name, comment)
    end

    def close_connections
      self.prevent_connections

      master_connection.execute <<-SQL
        SELECT pg_terminate_backend(procpid)
        FROM pg_stat_activity
        WHERE procpid <> pg_backend_pid()
        AND datname = '#{name}'
      SQL
    end

    def connection_config
      Pgas.public_connection_config.merge('database'=> self.name)
    end

    def connection
      @connection ||= ActiveRecord::Base.postgresql_connection(self.connection_config)
    end

    def to_yaml
      connection_config.to_yaml
    end
  end
end
