require 'spec_helper'

module RailsBestPractices::Core
  describe ModelAttributes do
    let(:model_attributes) { ModelAttributes.new }

    before :each do
      model_attributes.add_attribute("Post", "title", :string)
      model_attributes.add_attribute("Post", "user_id", :integer)
    end

    it "should get model attributes" do
      expect(model_attributes.get_attribute_type("Post", "title")).to eq(:string)
      expect(model_attributes.get_attribute_type("Post", "user_id")).to eq(:integer)
      expect(model_attributes.get_attribute_type("Post", "unknonw")).to be_nil
    end

    it "should check is model attributes" do
      expect(model_attributes.is_attribute?("Post", "title")).to be true
      expect(model_attributes.is_attribute?("Post", "user_id")).to be true
      expect(model_attributes.is_attribute?("Post", "unknonw")).to be false
    end
  end
end
