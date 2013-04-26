require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe ModelPrepare do
      let(:runner) { Core::Runner.new(prepares: ModelPrepare.new) }

      context "models" do
        it "class_name with modules ::" do
          content =<<-EOF
          class Blog::Post < ActiveRecord::Base
          end
          EOF
          runner.prepare("app/models/admin/post.rb", content)
          models = Prepares.models
          models.map(&:to_s).should == ["Blog::Post"]
        end

        it "class_name with modules" do
          content =<<-EOF
          module Blog
            class Post < ActiveRecord::Base
            end
          end
          EOF
          runner.prepare("app/models/admin/post.rb", content)
          models = Prepares.models
          models.map(&:to_s).should == ["Blog::Post"]
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
          model_associations = Prepares.model_associations
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
            model_associations = Prepares.model_associations
            model_associations.get_association("Post", "author").should == {"meta" => "belongs_to", "class_name" => "Person"}
          end

          it "should parse has_one" do
            content =<<-EOF
            class Project < ActiveRecord::Base
              has_one :project_manager, "class_name" => "Person"
            end
            EOF
            runner.prepare("app/models/post.rb", content)
            model_associations = Prepares.model_associations
            model_associations.get_association("Project", "project_manager").should == {"meta" => "has_one", "class_name" => "Person"}
          end

          it "should parse has_many" do
            content =<<-EOF
            class Project < ActiveRecord::Base
              has_many :people, "class_name" => "Person"
            end
            EOF
            runner.prepare("app/models/project.rb", content)
            model_associations = Prepares.model_associations
            model_associations.get_association("Project", "people").should == {"meta" => "has_many", "class_name" => "Person"}
          end

          it "should parse has_and_belongs_to_many" do
            content =<<-EOF
            class Citizen < ActiveRecord::Base
              has_and_belongs_to_many :nations, "class_name" => "Country"
            end
            EOF
            runner.prepare("app/models/citizen.rb", content)
            model_associations = Prepares.model_associations
            model_associations.get_association("Citizen", "nations").should == {"meta" => "has_and_belongs_to_many", "class_name" => "Country"}
          end

          context "namespace" do
            it "should parse with namespace" do
              content =<<-EOF
              class Community < ActiveRecord::Base
                has_many :members
              end
              EOF
              runner.prepare("app/models/community.rb", content)
              content =<<-EOF
              class Community::Member < ActiveRecord::Base
                belongs_to :community
              end
              EOF
              runner.prepare("app/models/community/member.rb", content)
              runner.after_prepare
              model_associations = Prepares.model_associations
              model_associations.get_association("Community", "members").should == {"meta" => "has_many", "class_name" => "Community::Member"}
              model_associations.get_association("Community::Member", "community").should == {"meta" => "belongs_to", "class_name" => "Community"}
            end

            it "should parse without namespace" do
              content =<<-EOF
              class Community::Member::Rating < ActiveRecord::Base
                belongs_to :member
              end
              EOF
              runner.prepare("app/models/community/member/rating.rb", content)
              content =<<-EOF
              class Community::Member < ActiveRecord::Base
                has_many :ratings
              end
              EOF
              runner.prepare("app/models/community/member.rb", content)
              runner.after_prepare
              model_associations = Prepares.model_associations
              model_associations.get_association("Community::Member::Rating", "member").should == {"meta" => "belongs_to", "class_name" => "Community::Member"}
              model_associations.get_association("Community::Member", "ratings").should == {"meta" => "has_many", "class_name" => "Community::Member::Rating"}
            end
          end
        end

        context "mongoid embeds" do
          it "should parse embeds_many" do
            content =<<-EOF
            class Person
              include Mongoid::Document
              embeds_many :addresses
            end
            EOF
            runner.prepare("app/models/person.rb", content)
            model_associations = Prepares.model_associations
            model_associations.get_association("Person", "addresses").should == {"meta" => "embeds_many", "class_name" => "Address"}
          end

          it "should parse embeds_one" do
            content =<<-EOF
            class Lush
              include Mongoid::Document
              embeds_one :whiskey, class_name: "Drink", inverse_of: :alcoholic
            end
            EOF
            runner.prepare("app/models/lush.rb", content)
            model_associations = Prepares.model_associations
            model_associations.get_association("Lush", "whiskey").should == {"meta" => "embeds_one", "class_name" => "Drink"}
          end

          it "should parse embedded_in" do
            content =<<-EOF
            class Drink
              include Mongoid::Document
              embedded_in :alcoholic, class_name: "Lush", inverse_of: :whiskey
            end
            EOF
            runner.prepare("app/models/drink.rb", content)
            model_associations = Prepares.model_associations
            model_associations.get_association("Drink", "alcoholic").should == {"meta" => "embedded_in", "class_name" => "Lush"}
          end
        end

        context "mongomapper many/one" do
          it "should parse one" do
            content =<<-EOF
            class Employee
              include MongoMapper::Document
              one :desk
            end
            EOF
            runner.prepare("app/models/employee.rb", content)
            model_associations = Prepares.model_associations
            model_associations.get_association("Employee", "desk").should == {"meta" => "one", "class_name" => "Desk"}
          end

          it "should parse many" do
            content =<<-EOF
            class Tree
              include MongoMapper::Document
              many :birds
            end
            EOF
            runner.prepare("app/models/tree.rb", content)
            model_associations = Prepares.model_associations
            model_associations.get_association("Tree", "birds").should == {"meta" => "many", "class_name" => "Bird"}
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
          methods = Prepares.model_methods
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
          methods = Prepares.model_methods
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
          methods = Prepares.model_methods
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
          methods = Prepares.model_methods
          methods.get_methods("Admin::Blog::Post").map(&:method_name).should == ["save", "find"]
        end

        it "should not add methods from module" do
          content =<<-EOF
            class Model < ActiveRecord::Base
            end
          EOF
          runner.prepare("app/models/model.rb", content)
          content =<<-EOF
            module Mixin
              def mixed_method
              end
            end
          EOF
          runner.prepare("app/models/mixins/mixin.rb", content)
          methods = Prepares.model_methods
          methods.get_methods('Model').should be_empty
        end
      end

      context "scope" do
        it "should treat named_scope as method" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            named_scope :active, conditions: {active: true}
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          methods = Prepares.model_methods
          methods.get_methods("Post").map(&:method_name).should == ["active"]
        end

        it "should treat scope as method" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            scope :active, where(active: true)
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          methods = Prepares.model_methods
          methods.get_methods("Post").map(&:method_name).should == ["active"]
        end
      end

      context "alias" do
        it "should treat alias as method" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            alias :new :old
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          methods = Prepares.model_methods
          methods.get_methods("Post").map(&:method_name).should == ["new"]
        end

        it "should treat alias_method as method" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            alias_method :new, :old
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          methods = Prepares.model_methods
          methods.get_methods("Post").map(&:method_name).should == ["new"]
        end

        it "should treat alias_method_chain as method" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            alias_method_chain :method, :feature
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          methods = Prepares.model_methods
          methods.get_methods("Post").map(&:method_name).should == ["method_with_feature", "method"]
        end
      end

      context "attributes" do
        it "should parse mongoid field" do
          content =<<-EOF
          class Post
            include Mongoid::Document
            field :title
            field :tags, type: Array
            field :comments_count, type: Integer
            field :deleted_at, type: DateTime
            field :active, type: Boolean
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          model_attributes = Prepares.model_attributes
          model_attributes.get_attribute_type("Post", "title").should == "String"
          model_attributes.get_attribute_type("Post", "tags").should == "Array"
          model_attributes.get_attribute_type("Post", "comments_count").should == "Integer"
          model_attributes.get_attribute_type("Post", "deleted_at").should == "DateTime"
          model_attributes.get_attribute_type("Post", "active").should == "Boolean"
        end

        it "should parse mongomapper field" do
          content =<<-EOF
          class Post
            include MongoMapper::Document
            key :first_name,  String
            key :last_name,   String
            key :age,         Integer
            key :born_at,     Time
            key :active,      Boolean
            key :fav_colors,  Array
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          model_attributes = Prepares.model_attributes
          model_attributes.get_attribute_type("Post", "first_name").should == "String"
          model_attributes.get_attribute_type("Post", "last_name").should == "String"
          model_attributes.get_attribute_type("Post", "age").should == "Integer"
          model_attributes.get_attribute_type("Post", "born_at").should == "Time"
          model_attributes.get_attribute_type("Post", "active").should == "Boolean"
          model_attributes.get_attribute_type("Post", "fav_colors").should == "Array"
        end
      end

      context "no error" do
        it "should raised for finder_sql option" do
          content =<<-EOF
          class EventSubscription < ActiveRecord::Base
            has_many :event_notification_template, finder_sql: ?
          end
          EOF
          content.sub!('?', '\'SELECT event_notification_templates.* from event_notification_templates where event_type_id=#{event_type_id} and delivery_method_id=#{delivery_method_id}\'')
          lambda { runner.prepare('app/models/event_subscription.rb', content) }.should_not raise_error
        end
      end
    end
  end
end
