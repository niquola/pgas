require 'spec_helper'
require 'logger'
ActiveRecord::Base.logger  = Logger.new(STDOUT)
describe Pgas::Database do

  before :each do
    %w[mydatabase clonedb].each do |name|
      database = Pgas::Database.new(name)
      database.drop if database.exists?
    end
  end

  it 'should create & drop database' do
    database = Pgas::Database.new('mydatabase', 'here is my comment')
    database.create
    Pgas::Database.all.should include(database)
    database.connection.execute('create table test ()')
    database.should have_connections
    database.tables.map(&:second).should include('test')
    database.size.should_not be_nil
    other_instance_database = Pgas::Database.new('mydatabase')
    other_instance_database.comment.should == database.comment

    database.connection.disconnect!
    database.should_not have_connections

    database = Pgas::Database.new('mydatabase', 'here is my comment')
    cloned_database = database.clone('clonedb')
    database.drop(true)
    database.exists?.should == false

    cloned_database.connection.select_all('select * from test')
    cloned_database.drop(true)
  end
end
