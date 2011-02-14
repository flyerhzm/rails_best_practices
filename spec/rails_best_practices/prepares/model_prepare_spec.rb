require 'spec_helper'

describe RailsBestPractices::Prepares::ModelPrepare do
  let(:runner) { RailsBestPractices::Core::Runner.new(:prepares => RailsBestPractices::Prepares::ModelPrepare.new) }

  it "should parse model associations" do
    content =<<-EOF
    class Project < ActiveRecord::Base
      belongs_to              :portfolio
      has_one                 :project_manager
      has_many                :milestones
      has_and_belongs_to_many :categories
    end
    EOF
    runner.prepare('app/models/project.rb', content)
    model_associations = RailsBestPractices::Prepares.model_associations
    model_associations["Project"]["portfolio"].should == :belongs_to
    model_associations["Project"]["project_manager"].should == :has_one
    model_associations["Project"]["milestones"].should == :has_many
    model_associations["Project"]["categories"].should == :has_and_belongs_to_many
  end
end
