require 'spec_helper'

module RailsBestPractices::Core
  describe ModelAssociations do
    let(:model_associations) { ModelAssociations.new }

    before :each do
      model_associations.add_association("Project", "project_manager", "belongs_to")
      model_associations.add_association("Project", "people", "has_many", "Person")
    end

    it "should get model associations" do
      model_associations.get_association("Project", "project_manager").should == {"meta" => "belongs_to", "class_name" => "ProjectManager"}
      model_associations.get_association("Project", "people").should == {"meta" => "has_many", "class_name" => "Person"}
      model_associations.get_association("Project", "unknown").should be_nil
    end

    it "should check is model associatiosn" do
      model_associations.is_association?("Project", "project_manager").should be_true
      model_associations.is_association?("Project", "people").should be_true
      model_associations.is_association?("Project", "unknown").should be_false
    end
  end
end
