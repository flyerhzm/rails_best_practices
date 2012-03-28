require 'spec_helper'

module RailsBestPractices::Core
  describe ModelAttributes do
    let(:model_attributes) { ModelAttributes.new }

    before :each do
      model_attributes.add_attribute("Post", "title", :string)
      model_attributes.add_attribute("Post", "user_id", :integer)
    end

    it "should get model attributes" do
      model_attributes.get_attribute_type("Post", "title").should == :string
      model_attributes.get_attribute_type("Post", "user_id").should == :integer
      model_attributes.get_attribute_type("Post", "unknonw").should be_nil
    end

    it "should check is model attributes" do
      model_attributes.is_attribute?("Post", "title").should be_true
      model_attributes.is_attribute?("Post", "user_id").should be_true
      model_attributes.is_attribute?("Post", "unknonw").should be_false
    end
  end
end
