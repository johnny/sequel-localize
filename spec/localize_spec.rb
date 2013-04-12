require File.join(File.dirname(__FILE__), 'spec_helper.rb')

describe 'description' do
  
  it 'should create translations' do
    a = Foo.first
    a.title('de').should == 'de'
    a.title('en').should == 'en'
  end
  
end
