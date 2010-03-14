require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::OveruseRouteCustomizationsCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::OveruseRouteCustomizationsCheck.new)
  end
  
  it "should overuse route customizations" do
    content = <<-EOF
    ActionController::Routing::Routes.draw do |map|
      map.resources :posts, :member => { :comments => :get,
                                         :create_comment => :post,
                                         :update_comment => :post,
                                         :delete_comment => :post }
    end
    EOF
    @runner.check('config/routes.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "config/routes.rb:2 - overuse route customizations (customize_count > 3)"
  end
  
  it "should overuse route customizations with collection" do
    content = <<-EOF
    ActionController::Routing::Routes.draw do |map|
      map.resources :posts, :member => { :create_comment => :post,
                                         :update_comment => :post,
                                         :delete_comment => :post },
                            :collection => { :comments => :get }
    end
    EOF
    @runner.check('config/routes.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "config/routes.rb:2 - overuse route customizations (customize_count > 3)"
  end

  it "should overuse route customizations with collection 2" do
    content = <<-EOF
    ActionController::Routing::Routes.draw do |map|
      map.resources :categories do |category|
        category.resources :posts, :member => { :create_comment => :post,
                                                :update_comment => :post,
                                                :delete_comment => :post },
                                   :collection => { :comments => :get }
      end
    end
    EOF
    @runner.check('config/routes.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "config/routes.rb:3 - overuse route customizations (customize_count > 3)"
  end
  
  it "should not overuse route customizations without customization" do
    content = <<-EOF
    ActionController::Routing::Routes.draw do |map|
      map.resources :posts
    end
    EOF
    @runner.check('config/routes.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not overuse route customizations when customize route is only one" do
    content = <<-EOF
    ActionController::Routing::Routes.draw do |map|
      map.resources :posts, :member => { :vote => :post }
    end
    EOF
    @runner.check('config/routes.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
