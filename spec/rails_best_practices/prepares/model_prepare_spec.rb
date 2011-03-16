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
    model_associations["Project"]["portfolio"].should == {:belongs_to => "Portfolio"}
    model_associations["Project"]["project_manager"].should == {:has_one => "ProjectManager"}
    model_associations["Project"]["milestones"].should == {:has_many => "Milestone"}
    model_associations["Project"]["categories"].should == {:has_and_belongs_to_many => "Category"}
  end

  context "class_name" do
    it "should parse belongs_to" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        belongs_to :author, :class_name => "Person"
      end
      EOF
      runner.prepare("app/models/post.rb", content)
      model_associations = RailsBestPractices::Prepares.model_associations
      model_associations["Post"]["author"].should == {:belongs_to => "Person"}
    end

    it "should parse has_one" do
      content =<<-EOF
      class Project < ActiveRecord::Base
        has_one :project_manager, :class_name => "Person"
      end
      EOF
      runner.prepare("app/models/post.rb", content)
      model_associations = RailsBestPractices::Prepares.model_associations
      model_associations["Project"]["project_manager"].should == {:has_one => "Person"}
    end

    it "should parse has_many" do
      content =<<-EOF
      class Project < ActiveRecord::Base
        has_many :people, :class_name => "Person"
      end
      EOF
      runner.prepare("app/models/project.rb", content)
      model_associations = RailsBestPractices::Prepares.model_associations
      model_associations["Project"]["people"].should == {:has_many => "Person"}
    end

    it "should parse has_and_belongs_to_many" do
      content =<<-EOF
      class Citizen < ActiveRecord::Base
        has_and_belongs_to_many :nations, :class_name => "Country"
      end
      EOF
      runner.prepare("app/models/citizen.rb", content)
      model_associations = RailsBestPractices::Prepares.model_associations
      model_associations["Citizen"]["nations"].should == {:has_and_belongs_to_many => "Country"}
    end
  end
end
