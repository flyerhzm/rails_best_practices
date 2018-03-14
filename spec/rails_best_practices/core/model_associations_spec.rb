# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices::Core
  describe ModelAssociations do
    let(:model_associations) { ModelAssociations.new }

    before :each do
      model_associations.add_association('Project', 'project_manager', 'belongs_to')
      model_associations.add_association('Project', 'people', 'has_many', 'Person')
    end

    it 'should get model associations' do
      expect(model_associations.get_association('Project', 'project_manager')).to eq({'meta' => 'belongs_to', 'class_name' => 'ProjectManager'})
      expect(model_associations.get_association('Project', 'people')).to eq({'meta' => 'has_many', 'class_name' => 'Person'})
      expect(model_associations.get_association('Project', 'unknown')).to be_nil
    end

    it 'should check is model associatiosn' do
      expect(model_associations.is_association?('Project', 'project_manager')).to eq true
      expect(model_associations.is_association?('Project', 'people')).to eq true
      expect(model_associations.is_association?('Project', 'unknown')).to eq false
    end
  end
end
