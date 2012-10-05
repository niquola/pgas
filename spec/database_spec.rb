require 'spec_helper'
require 'logger'
ActiveRecord::Base.logger  = Logger.new(STDOUT)
describe Pgas::Database do
  class Model < ActiveRecord::Base
  end

  let(:config) { Pgas.connection_config }
  let(:connection) { Pgas.connection }

  it 'should create & drop database' do
    database = Pgas::Database.new(connection,'mydatabase', 'here is my comment')
    database.drop if database.exists?
    database.create
    Model.establish_connection(config.merge('database'=> 'mydatabase'))
    Model.connection.execute('create table test ()')
    Pgas::Database.all(connection).should include(database)
    database.should have_connections
    #database.tables.map(&:second).should include('test')
    database.size.should_not be_nil
    other_instance_database = Pgas::Database.new(connection,'mydatabase')
    other_instance_database.comment.should == database.comment

    Model.connection_pool.disconnect!

    database.should_not have_connections

    cloned_database = database.clone('clonedb')
    database.drop(true)
    database.exists?.should == false

    Model.establish_connection(config.merge('database'=> 'clonedb'))
    Model.connection.select_all('select * from test')
    cloned_database.drop(true)
  end
end
