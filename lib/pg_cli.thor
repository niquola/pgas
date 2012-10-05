require 'pgas'
class Pg < Thor
  desc "list", "list databases"
  method_options %w(verbose -v) => :boolean
  def list(*args)
    puts "Databases:"
    puts "=========="
    Pgas::Database.all(connection).each do |db|
      if options[:verbose]
        puts "#{db.database_name}: #{db.comment}"
      else
        puts db.database_name
      end
    end
  end

  desc "create DATABASE [COMMENT]", "create database or fail if exists"
  def create(name, comment=nil)
    db = Pgas::Database.new(connection, name, comment)
    db.create
    puts config(db.database_name).to_yaml
  end

  desc "psql DATABSE", "open psql on this database"
  def psql(name)
    options = ""
  end

  desc "drop DATABASE1 DATABASE2", "drop databases"
  def drop(*names)
    if names.empty?
      names = []
      while name = STDIN.gets do
        names<< name.chomp
      end
    end
    names.each do |name|
      begin
        puts "Dropping #{name}"
        db = Pgas::Database.new(connection, name)
        db.drop
      rescue Exception => e
        p e
      end
    end
  end

  no_tasks do
    def connection
      Pgas.connection
    end

    def config(name)
      Pgas.public_connection_config.merge('database' => name)
    end
  end
end
