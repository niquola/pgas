module Pgas
  class Role
    def self.all(connection)
      connection.select_values("SELECT rolname FROM pg_roles").map do |name|
	self.new(connection, name)
      end
    end

    attr :name
    def initialize(connection, name)
      @connection = connection
      @name = name
    end

    def attributes
      @attributes ||= @connection.send(:select,"select * from pg_roles where rolname = '#{self.name}'").first
    end

    def exists?
      @connection.select_value("SELECT rolname FROM pg_roles WHERE rolname = '#{self.name}'") == name
    end
  end
end
