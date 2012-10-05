require 'spec_helper'
require 'logger'
ActiveRecord::Base.logger  = Logger.new(STDOUT)
describe Pgas::PgStatActivity do
  let(:config) { Pgas.connection_config }
  before(:all) { Pgas::PgStatActivity.establish_connection config }
  it do
    Pgas::PgStatActivity.for('postgres').should_not be_empty
  end
end
