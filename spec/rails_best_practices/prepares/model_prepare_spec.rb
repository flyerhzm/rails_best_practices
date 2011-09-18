require 'spec_helper'

describe RailsBestPractices::Prepares::ModelPrepare do
  let(:runner) { RailsBestPractices::Core::Runner.new(:prepares => RailsBestPractices::Prepares::ModelPrepare.new) }

  before :each do
    runner.whiny = true
  end

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
    model_associations.get_association("Project", "portfolio").should == {"meta" => "belongs_to", "class_name" => "Portfolio"}
    model_associations.get_association("Project", "project_manager").should == {"meta" => "has_one", "class_name" => "ProjectManager"}
    model_associations.get_association("Project", "milestones").should == {"meta" => "has_many", "class_name" => "Milestone"}
    model_associations.get_association("Project", "categories").should == {"meta" => "has_and_belongs_to_many", "class_name" => "Category"}
  end

  it "should not raise error for finder_sql option" do
    content =<<-EOF
    class EventSubscription < ActiveRecord::Base
      has_many :event_notification_template, :finder_sql => ?
    end
    EOF
    content.sub!('?', '\'SELECT event_notification_templates.* from event_notification_templates where event_type_id=#{event_type_id} and delivery_method_id=#{delivery_method_id}\'')
    lambda { runner.prepare('app/models/event_subscription.rb', content) }.should_not raise_error
  end

  context "class_name" do
    it "should parse belongs_to" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        belongs_to :author, "class_name" => "Person"
      end
      EOF
      runner.prepare("app/models/post.rb", content)
      model_associations = RailsBestPractices::Prepares.model_associations
      model_associations.get_association("Post", "author").should == {"meta" => "belongs_to", "class_name" => "Person"}
    end

    it "should parse has_one" do
      content =<<-EOF
      class Project < ActiveRecord::Base
        has_one :project_manager, "class_name" => "Person"
      end
      EOF
      runner.prepare("app/models/post.rb", content)
      model_associations = RailsBestPractices::Prepares.model_associations
      model_associations.get_association("Project", "project_manager").should == {"meta" => "has_one", "class_name" => "Person"}
    end

    it "should parse has_many" do
      content =<<-EOF
      class Project < ActiveRecord::Base
        has_many :people, "class_name" => "Person"
      end
      EOF
      runner.prepare("app/models/project.rb", content)
      model_associations = RailsBestPractices::Prepares.model_associations
      model_associations.get_association("Project", "people").should == {"meta" => "has_many", "class_name" => "Person"}
    end

    it "should parse has_and_belongs_to_many" do
      content =<<-EOF
      class Citizen < ActiveRecord::Base
        has_and_belongs_to_many :nations, "class_name" => "Country"
      end
      EOF
      runner.prepare("app/models/citizen.rb", content)
      model_associations = RailsBestPractices::Prepares.model_associations
      model_associations.get_association("Citizen", "nations").should == {"meta" => "has_and_belongs_to_many", "class_name" => "Country"}
    end
  end
end
