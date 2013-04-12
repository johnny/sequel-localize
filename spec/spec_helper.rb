$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'

require 'sequel'
require 'sequel-localize'
require 'rspec'
require 'rspec/autorun'

DB = Sequel.sqlite
Sequel::Model.plugin :schema

require 'support/classes'
#require 'shared_specs'


RSpec.configure do |config|
  #config.include RoleModel::InstanceMethods
end

