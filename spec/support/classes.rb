DB.create_table :post_translations do
  primary_key :id
  String :title
  String :subtitle
  integer :language_id
  integer :post_id
end

DB.create_table :posts do
  primary_key :id
  String :uri
  String :type
end

DB[:languages] << {"name"=>"en", "code" => 'en'}
DB[:languages] << {"name"=>"de", "code" => 'de'}


class Post < Sequel::Model
  plugin :localize
  plugin :single_table_inheritance, :type
  
  def validate
    super
    validates_presence [:uri]
  end
end

class SpecialPost < Post
  
end

class PostTranslation < Sequel::Model
  def validate
    super
    validates_presence [:title]
  end
end
