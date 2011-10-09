require 'spec_helper'

describe RailsBestPractices::Core::Methods do
  let(:methods) { RailsBestPractices::Core::Methods.new }

  before :each do
    methods.add_method("Post", "create")
    methods.add_method("Post", "destroy")
    methods.add_method("Post", "save_or_update", {}, "protected")
    methods.add_method("Post", "find_by_sql", {}, "private")
    methods.add_method("Comment", "create")
  end

  it "should get_methods" do
    methods.get_methods("Post").map(&:name).should == ["create", "destroy", "save_or_update", "find_by_sql"]
    methods.get_methods("Post", "public").map(&:name).should == ["create", "destroy"]
    methods.get_methods("Post", "protected").map(&:name).should == ["save_or_update"]
    methods.get_methods("Post", "private").map(&:name).should == ["find_by_sql"]
    methods.get_methods("Comment").map(&:name).should == ["create"]
  end

  it "should has_method?" do
    methods.should be_has_method("Post", "create", "public")
    methods.should be_has_method("Post", "destroy", "public")
    methods.should_not be_has_method("Post", "save_or_update", "public")
    methods.should be_has_method("Post", "save_or_update", "protected")
    methods.should_not be_has_method("Post", "find_by_sql", "public")
    methods.should be_has_method("Post", "find_by_sql", "private")
    methods.should_not be_has_method("Comment", "destroy")
  end

  it "should get_method" do
    methods.get_method("Post", "create", "public").should_not be_nil
    methods.get_method("Post", "create", "protected").should be_nil
  end

  it "should get_uused_methods" do
    methods.get_methods("Post", "public").map(&:name).should == ["create", "destroy"]
    methods.get_methods("Post", "protected").map(&:name).should == ["save_or_update"]
    methods.get_methods("Post", "private").map(&:name).should == ["find_by_sql"]
    methods.get_methods("Comment").map(&:name).should == ["create"]
  end
end
