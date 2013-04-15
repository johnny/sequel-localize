require File.join(File.dirname(__FILE__), 'spec_helper.rb')

describe 'description' do
  
  it 'should create translations' do
    a = create_post
    a.title(:de).should == 'de'
    a.title('en').should == 'en'
  end

  it 'should hold translations before save' do
    x = new_post
    x.title(:de).should == 'de'
    x.title('en').should == 'en'
  end

  it 'should update translations' do
    a = create_post
    a.update(:en => {:title => 'en up'}, :de => {:title => 'de up'})
    a.title(:de).should == 'de up'
    a.title(:en).should == 'en up'
  end

  it 'should add error if attribute missing' do
    a = Post.new(:de => {:title => ''}, :uri => '')
    a.save
    a.errors.on(:uri).should be_true
    a.errors.on(:de).should be_true
    a.errors.on(:de).first.on(:title).should be_true
    a.errors.on(:en).should be_false

    a = Post.new('de' => {:title => ''}, 'en' => {:subtitle => 'asd'}, :uri => '')
    a.save
    a.errors.on(:uri).should be_true
    a.errors.on(:de).should be_true
    a.errors.on(:de).first.on(:title).should be_true
    a.errors.on(:en).should be_true
    a.errors.on(:en).first.on(:title).should be_true
  end
  
  it 'should add error if a new translation is not valid' do
    a = Post.new(:uri => 'test',
                 :de => {
                   :title => 'de'
                 })
    a.save.should be_true
    a.update(:en => { :subtitle => 'bla'}).should be(false)

    a.update(:en => {:title => 'en up'}, :de => { :title => '' }).should be(false)
  end

  it 'should create new setters on the fly' do
    l = Language[:xy]
    a = Post.new(:uri => 'test',
                 :xy => {
                   :title => 'xy'
                 })
    a.title(:xy).should == 'xy'
    a.xy.should be_true
  end
  
  def new_post
    Post.new(:uri => 'test',
             :de => {
               :title => 'de'
             },
             :en => {
               :title => 'en'
             }
             )
  end
  def create_post
    post = new_post
    post.save.should be_true
    post
  end
end
