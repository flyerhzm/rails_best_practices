require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::NotUseDefaultRouteCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::NotUseDefaultRouteCheck.new)
  end
  
  it "should not use default route" do
    content = <<-EOF
    ActionController::Routing::Routes.draw do |map|
      map.resources :posts, :member => { :push => :post }
      
      map.connect ':controller/:action/:id'
      map.connect ':controller/:action/:id.:format'
    end
    EOF
    @runner.check('config/routes.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "config/routes.rb:4 - not use default route"
    errors[1].to_s.should == "config/routes.rb:5 - not use default route"
  end

  it "should no not use default route" do
    content = <<-EOF
    ActionController::Routing::Routes.draw do |map|
      map.resources :posts, :member => { :push => :post }
    end
    EOF
    @runner.check('config/routes.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end