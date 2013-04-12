DB.create_table :foo_translations do
  primary_key :id
  String :title
  integer :language_id
  integer :foo_id
end


class Foo < Sequel::Model
  set_schema do
    primary_key :id
    varchar :name
  end
  plugin :localization
end

class Language < Sequel::Model
  set_schema do
    primary_key :id
    varchar :code #unique
    varchar :name
  end

  # locale string like 'en'
  # validates_format_of :code, :with => /^[a-z]{2}$/


  class << self
    def [](code)
      return nil if code.nil?
      (@cache ||= {})[code] ||= first(:code => code) || create(:code => code, :name => code)
    end
  end
end

[Foo, Language].each {|klass| klass.create_table!}
DB[:languages] << {"name"=>"en", "code" => 'en'}
DB[:languages] << {"name"=>"de", "code" => 'de'}
DB[:foos] << {"name" => "bla"}
DB[:foo_translations] << {"title" => "de", "language_id" => Language.find(:code => 'de').id, "foo_id" => Foo.first.id}
DB[:foo_translations] << {"title" => "en", "language_id" => Language.find(:code => 'en').id, "foo_id" => Foo.first.id}

