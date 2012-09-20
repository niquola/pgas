require 'spec_helper'
describe Pgas::DbManager do
  subject { Pgas::DbManager.new(Pgas.connection_config) }
  it "should create required database" do
    config = subject.create_db('just_db')
    config['database'].should == 'just_db'
    test_connection(config)
    -> { config = subject.create_db('just_db') }
    .should raise_error(Pgas::DbAlreadyExistsError)
  end

  it "should return copy of template database" do
    c = conn(subject.create_db('just_db'))
    c.exec "create table just_test ();"
    c.close
    config = subject.create_db('mytestdb', template: 'just_db')
    config['database'].should  == 'mytestdb'
    test_connection(config)
    c = conn(config)
    c.exec "select * from just_test"
    c.close
  end

  after :each do
    subject.drop_db('just_db')
    subject.drop_db('mytestdb')
  end

  before :each do
    subject.drop_db('just_db')
    subject.drop_db('mytestdb')
  end

  def conn(config)
    cfg = config.dup
    cfg['dbname'] = cfg.delete('database')
    conn = PG.connect(cfg)
  end

  def test_connection(config)
    c = conn(config)
    c.exec "select 1"
    c.close
  end
end
