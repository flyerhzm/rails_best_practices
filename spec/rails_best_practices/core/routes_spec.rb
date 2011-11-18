require 'spec_helper'

describe RailsBestPractices::Core::Routes do
  let(:routes) { RailsBestPractices::Core::Routes.new }

  it "should add route" do
    routes.add_route(["admin", "test"], "posts", "new")
    routes.map(&:to_s).should == ["Admin::Test::PostsController#new"]
  end
end
