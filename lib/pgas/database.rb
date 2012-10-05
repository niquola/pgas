module Pgas
  class Database
    attr_reader :database_name
    attr_reader :connection
    attr_reader :comment

    def self.all(connection)
      connection.select_values('SELECT datname FROM pg_database').sort.map do |name|
        self.new(connection,name)
      end
    end

    def comment
      @comment ||= get_comment
    end

    def get_comment
    end

    #override equality
    def ==(other)
      other.database_name == database_name
    end

    def initialize(connection, database_name, comment = nil)
      @connection = connection
      @database_name = database_name
      @comment = comment
    end

    def create
      #FIXME: sanitize all params
      connection.execute "CREATE DATABASE #{database_name}"
      connection.execute "COMMENT ON DATABASE #{database_name} IS '#{comment}'" if comment
    end

    def tables
      connection.select_rows <<-SQL
	select * from pg_catalog.pg_tables order by  tablename
	SQL

    end

    def size
      connection.select_value "select pg_size_pretty(pg_database_size('#{self.database_name}'))"
    end

    def drop(force = false)
      fail "Database #{database_name} not exists?" unless self.exists?
      fail "Database #{database_name} in use" if not force and  self.has_connections?
      self.close_connections if force
      connection.execute %(DROP DATABASE "#{database_name}";)
    end

    def exists?
      connection.select_value("select 1 from pg_database where datname = '#{database_name}'") == '1'
    end

    def activity_stat
      connection.select_all <<-SQL
        SELECT *
        FROM pg_stat_activity
        WHERE datname = '#{database_name}'
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
      connection.execute <<-SQL
        REVOKE CONNECT
        ON DATABASE #{database_name}
        FROM #{users.join(', ')}
        SQL
    end

    def comment
      @comment ||= connection.select_value "SELECT description FROM pg_shdescription WHERE objoid = (SELECT oid FROM pg_database WHERE datname = '#{self.database_name}')"
    end

    def clone(clone_name, comment = nil)
      fail "Template database #{database_name} is being accessed" if self.has_connections?
      connection.execute "CREATE DATABASE #{clone_name} WITH TEMPLATE #{database_name}"
      connection.execute "COMMENT ON DATABASE #{clone_name} IS '#{comment}'" if comment

      Database.new(connection, clone_name, comment)
    end

    def close_connections
      self.prevent_connections

      connection.execute <<-SQL
        SELECT pg_terminate_backend(procpid)
        FROM pg_stat_activity
        WHERE procpid <> pg_backend_pid()
        AND datname = '#{database_name}'
      SQL
    end

    def to_yaml
      Pgas.public_connection_config.merge('database'=> self.database_name).to_yaml
    end
  end
end
