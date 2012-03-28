require 'spec_helper'

module RailsBestPractices::Core
  describe Methods do
    let(:methods) { Methods.new }

    before :each do
      methods.add_method("Post", "create")
      methods.add_method("Post", "destroy")
      methods.add_method("Post", "save_or_update", {}, "protected")
      methods.add_method("Post", "find_by_sql", {}, "private")
      methods.add_method("Comment", "create")
    end

    it "should get_methods" do
      methods.get_methods("Post").map(&:method_name).should == ["create", "destroy", "save_or_update", "find_by_sql"]
      methods.get_methods("Post", "public").map(&:method_name).should == ["create", "destroy"]
      methods.get_methods("Post", "protected").map(&:method_name).should == ["save_or_update"]
      methods.get_methods("Post", "private").map(&:method_name).should == ["find_by_sql"]
      methods.get_methods("Comment").map(&:method_name).should == ["create"]
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

    it "should get_all_unused_methods" do
      methods.get_method("Comment", "create").mark_used
      methods.get_all_unused_methods("public").map(&:method_name).should == ["create", "destroy"]
      methods.get_all_unused_methods("protected").map(&:method_name).should == ["save_or_update"]
      methods.get_all_unused_methods("private").map(&:method_name).should == ["find_by_sql"]
      methods.get_all_unused_methods.map(&:method_name).should == ["create", "destroy", "save_or_update", "find_by_sql"]
    end
  end
end
