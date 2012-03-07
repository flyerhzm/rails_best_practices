require 'spec_helper'

describe RailsBestPractices::Core::Routes do
  let(:routes) { RailsBestPractices::Core::Routes.new }

  it "should add route" do
    routes.add_route(["admin", "test"], "posts", "new")
    routes.map(&:to_s).should == ["Admin::Test::PostsController#new"]
  end

  context "route" do
    it "should add namesapces, controller name and action name" do
      route = RailsBestPractices::Core::Route.new(['admin', 'test'], 'posts', 'new')
      route.to_s.should == "Admin::Test::PostsController#new"
    end

    it "should add controller name with namespace" do
      route = RailsBestPractices::Core::Route.new(['admin'], 'test/posts', 'new')
      route.to_s.should == "Admin::Test::PostsController#new"
    end

    it "should add routes without controller" do
      route = RailsBestPractices::Core::Route.new(['posts'], nil, 'new')
      route.to_s.should == "PostsController#new"
    end
  end
end
