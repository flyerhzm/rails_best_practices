require 'spec_helper'

describe RailsBestPractices::Core::Methods do
  let(:methods) { RailsBestPractices::Core::Methods.new }

  before :each do
    methods.add_method("Post", "create")
    methods.add_method("Post", "destroy")
    methods.add_method("Comment", "create")
  end

  it "should get_methods" do
    methods.get_methods("Post").to_a.should == ["create", "destroy"]
    methods.get_methods("Comment").to_a.should == ["create"]
  end

  it "should has_method?" do
    methods.should be_has_method("Post", "create")
    methods.should be_has_method("Post", "destroy")
    methods.should_not be_has_method("Comment", "destroy")
  end
end
