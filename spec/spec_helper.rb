$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'

require 'sequel'
require 'rspec'
require 'rspec/autorun'

DB = Sequel.sqlite
Sequel::Model.plugin :validation_helpers
Sequel::Model.raise_on_save_failure = false

DB.create_table :languages do
  primary_key :id
  String :code
  String :name
end

require 'sequel/localize'

require 'logger'
DB.logger = Logger.new('db.log')

require 'support/classes'
#require 'shared_specs'

