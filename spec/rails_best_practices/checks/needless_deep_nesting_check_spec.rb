require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::NeedlessDeepNestingCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::NeedlessDeepNestingCheck.new)
  end
  
  it "should needless deep nesting" do
    content = <<-EOF
    map.resources :posts do |post|
      post.resources :comments do |comment|
        comment.resources :favorites
      end
    end
    EOF
    @runner.check('config/routes.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "config/routes.rb:3 - needless deep nesting (nested_count > 2)"
  end

  it "should no needless deep nesting" do
    content = <<-EOF
    map.resources :posts do |post|
      post.resources :comments
    end
    
    map.resources :comments do |comment|
      comment.resources :favorites
    end
    EOF
    @runner.check('config/routes.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end