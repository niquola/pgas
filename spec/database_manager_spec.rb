require 'spec_helper'
require 'logger'
ActiveRecord::Base.logger  = Logger.new(STDOUT)
describe Pgas::DatabasesManager do
  class Model < ActiveRecord::Base
  end

  let(:config) { Pgas.connection_config }
  subject { Pgas::DatabasesManager.new(config) }

  it 'should create & drop database' do
    connection_config = subject.create(generate_name('mydatabase'), 'here is my comment')
    database_name = connection_config['database']
    Model.establish_connection(connection_config)
    Model.connection.execute('create table test ()')

    subject.get_connection(database_name).should == connection_config
    subject.list.should include(database_name)

    clone_name = generate_name('my_template')
    Model.connection_pool.disconnect!
    clone_connection_config = subject.clone(database_name, clone_name)
    subject.drop(database_name, true)
    subject.exists?(database_name).should be_false

    Model.establish_connection(clone_connection_config)
    Model.connection.select_all('select * from test')
    subject.drop(clone_name, true)
  end

  def generate_name(prefix)
    now = Time.now.strftime('%Y%m%d%H%M%S')
    "#{prefix}_#{now}"
  end
end
