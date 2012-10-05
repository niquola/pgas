class Pgas::PgStatActivity < ActiveRecord::Base
  self.table_name = 'pg_stat_activity'
  scope :for, lambda{|db_name| self.where(datname: db_name) }
end
