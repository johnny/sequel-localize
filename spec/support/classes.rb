DB.create_table :foo_translations do
  primary_key :id
  String :title
  integer :language_id
  integer :foo_id
end

DB.create_table :languages do
  primary_key :id
  String :code
  String :name
end

DB.create_table :foos do
  primary_key :id
  String :name
end

DB[:languages] << {"name"=>"en", "code" => 'en'}
DB[:languages] << {"name"=>"de", "code" => 'de'}

class Language < Sequel::Model
  # locale string like 'en'
  # validates_format_of :code, :with => /^[a-z]{2}$/

  class << self
    def [](code)
      return nil if code.nil?
      (@cache ||= {})[code] ||= first(:code => code) || create(:code => code, :name => code)
    end
  end
end

class Foo < Sequel::Model
  plugin :localization
end


DB[:foos] << {"id" => 1, "name" => "bla"}
DB[:foo_translations] << {"title" => "de", "language_id" => Language.find(:code => 'de').id, "foo_id" => Foo.first.id}
DB[:foo_translations] << {"title" => "en", "language_id" => Language.find(:code => 'en').id, "foo_id" => Foo.first.id}

