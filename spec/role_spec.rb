require 'spec_helper'
require 'logger'
ActiveRecord::Base.logger  = Logger.new(STDOUT)
describe Pgas::Role do
  let (:connection) { Pgas.connection }
  it "" do
    role = Pgas::Role.all(connection).first
    role.exists?.should == true
    p role.attributes
  end
end
