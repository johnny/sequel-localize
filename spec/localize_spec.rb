require File.join(File.dirname(__FILE__), 'spec_helper.rb')

describe 'description' do
  
  it 'should create translations' do
    a = create_foo
    a.title(:de).should == 'de'
    a.title('en').should == 'en'
  end

  it 'should hold translations before save' do
    x = new_foo
    x.title(:de).should == 'de'
    x.title('en').should == 'en'
  end

  it 'should update translations' do
    a = create_foo
    a.update(:en => {:title => 'en up'}, :de => {:title => 'de up'})
    a.title(:de).should == 'de up'
    a.title(:en).should == 'en up'
  end

  def new_foo
    Foo.new(:name => 'test',
            :de => {
              :title => 'de'
            },
            :en => {
              :title => 'en'
            }
            )
  end
  def create_foo
    new_foo.tap{|o| o.save}
  end
end
