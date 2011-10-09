require 'spec_helper'

describe RailsBestPractices::Prepares::ModelPrepare do
  let(:runner) { RailsBestPractices::Core::Runner.new(:prepares => RailsBestPractices::Prepares::ModelPrepare.new) }

  before :each do
    runner.whiny = true
  end

  context "models" do
    it "class_name with modules ::" do
      content =<<-EOF
      class Blog::Post < ActiveRecord::Base
      end
      EOF
      runner.prepare("app/models/admin/post.rb", content)
      models = RailsBestPractices::Prepares.models
      models.should == ["Blog::Post"]
    end

    it "class_name with modules" do
      content =<<-EOF
      module Blog
        class Post < ActiveRecord::Base
        end
      end
      EOF
      runner.prepare("app/models/admin/post.rb", content)
      models = RailsBestPractices::Prepares.models
      models.should == ["Blog::Post"]
    end
  end

  context "associations" do
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

    context "with class_name option" do
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

  context "methods" do
    it "should parse model methods" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        def save; end
        def find; end
      end
      EOF
      runner.prepare("app/models/post.rb", content)
      methods = RailsBestPractices::Prepares.model_methods
      methods.get_methods("Post").map(&:method_name).should == ["save", "find"]
    end

    it "should parse model methods with access control" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        def save; end
        def find; end
        protected
        def create_or_update; end
        private
        def find_by_sql; end
      end
      EOF
      runner.prepare("app/models/post.rb", content)
      methods = RailsBestPractices::Prepares.model_methods
      methods.get_methods("Post").map(&:method_name).should == ["save", "find", "create_or_update", "find_by_sql"]
      methods.get_methods("Post", "public").map(&:method_name).should == ["save", "find"]
      methods.get_methods("Post", "protected").map(&:method_name).should == ["create_or_update"]
      methods.get_methods("Post", "private").map(&:method_name).should == ["find_by_sql"]
    end

    it "should parse model methods with module ::" do
      content =<<-EOF
      class Admin::Blog::Post < ActiveRecord::Base
        def save; end
        def find; end
      end
      EOF
      runner.prepare("app/models/admin/blog/post.rb", content)
      methods = RailsBestPractices::Prepares.model_methods
      methods.get_methods("Admin::Blog::Post").map(&:method_name).should == ["save", "find"]
    end

    it "should parse model methods with module" do
      content =<<-EOF
      module Admin
        module Blog
          class Post < ActiveRecord::Base
            def save; end
            def find; end
          end
        end
      end
      EOF
      runner.prepare("app/models/admin/blog/post.rb", content)
      methods = RailsBestPractices::Prepares.model_methods
      methods.get_methods("Admin::Blog::Post").map(&:method_name).should == ["save", "find"]
    end
  end

  context "no error" do
    it "should raised for finder_sql option" do
      content =<<-EOF
      class EventSubscription < ActiveRecord::Base
        has_many :event_notification_template, :finder_sql => ?
      end
      EOF
      content.sub!('?', '\'SELECT event_notification_templates.* from event_notification_templates where event_type_id=#{event_type_id} and delivery_method_id=#{delivery_method_id}\'')
      lambda { runner.prepare('app/models/event_subscription.rb', content) }.should_not raise_error
    end
  end
end
