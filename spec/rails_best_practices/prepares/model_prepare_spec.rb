# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe ModelPrepare do
      let(:runner) { Core::Runner.new(prepares: ModelPrepare.new) }

      context 'models' do
        it 'class_name with modules ::' do
          content = <<-EOF
          class Blog::Post < ActiveRecord::Base
          end
          EOF
          runner.prepare('app/models/admin/post.rb', content)
          models = Prepares.models
          expect(models.map(&:to_s)).to eq(['Blog::Post'])
        end

        it 'class_name with modules' do
          content = <<-EOF
          module Blog
            class Post < ActiveRecord::Base
            end
          end
          EOF
          runner.prepare('app/models/admin/post.rb', content)
          models = Prepares.models
          expect(models.map(&:to_s)).to eq(['Blog::Post'])
        end
      end

      context 'associations' do
        it 'should parse model associations' do
          content = <<-EOF
          class Project < ActiveRecord::Base
            belongs_to              :portfolio
            has_one                 :project_manager
            has_many                :milestones
            has_and_belongs_to_many :categories
          end
          EOF
          runner.prepare('app/models/project.rb', content)
          model_associations = Prepares.model_associations
          expect(model_associations.get_association('Project', 'portfolio')).to eq({ 'meta' => 'belongs_to', 'class_name' => 'Portfolio' })
          expect(model_associations.get_association('Project', 'project_manager')).to eq({ 'meta' => 'has_one', 'class_name' => 'ProjectManager' })
          expect(model_associations.get_association('Project', 'milestones')).to eq({ 'meta' => 'has_many', 'class_name' => 'Milestone' })
          expect(model_associations.get_association('Project', 'categories')).to eq({ 'meta' => 'has_and_belongs_to_many', 'class_name' => 'Category' })
        end

        context 'with class_name option' do
          it 'should parse belongs_to' do
            content = <<-EOF
            class Post < ActiveRecord::Base
              belongs_to :author, "class_name" => "Person"
            end
            EOF
            runner.prepare('app/models/post.rb', content)
            model_associations = Prepares.model_associations
            expect(model_associations.get_association('Post', 'author')).to eq({ 'meta' => 'belongs_to', 'class_name' => 'Person' })
          end

          it 'should parse has_one' do
            content = <<-EOF
            class Project < ActiveRecord::Base
              has_one :project_manager, "class_name" => "Person"
            end
            EOF
            runner.prepare('app/models/post.rb', content)
            model_associations = Prepares.model_associations
            expect(model_associations.get_association('Project', 'project_manager')).to eq({ 'meta' => 'has_one', 'class_name' => 'Person' })
          end

          it 'should parse has_many' do
            content = <<-EOF
            class Project < ActiveRecord::Base
              has_many :people, "class_name" => "Person"
            end
            EOF
            runner.prepare('app/models/project.rb', content)
            model_associations = Prepares.model_associations
            expect(model_associations.get_association('Project', 'people')).to eq({ 'meta' => 'has_many', 'class_name' => 'Person' })
          end

          it 'should parse has_and_belongs_to_many' do
            content = <<-EOF
            class Citizen < ActiveRecord::Base
              has_and_belongs_to_many :nations, "class_name" => "Country"
            end
            EOF
            runner.prepare('app/models/citizen.rb', content)
            model_associations = Prepares.model_associations
            expect(model_associations.get_association('Citizen', 'nations')).to eq({ 'meta' => 'has_and_belongs_to_many', 'class_name' => 'Country' })
          end

          context 'namespace' do
            it 'should parse with namespace' do
              content = <<-EOF
              class Community < ActiveRecord::Base
                has_many :members
              end
              EOF
              runner.prepare('app/models/community.rb', content)
              content = <<-EOF
              class Community::Member < ActiveRecord::Base
                belongs_to :community
              end
              EOF
              runner.prepare('app/models/community/member.rb', content)
              runner.after_prepare
              model_associations = Prepares.model_associations
              expect(model_associations.get_association('Community', 'members')).to eq({ 'meta' => 'has_many', 'class_name' => 'Community::Member' })
              expect(model_associations.get_association('Community::Member', 'community')).to eq({ 'meta' => 'belongs_to', 'class_name' => 'Community' })
            end

            it 'should parse without namespace' do
              content = <<-EOF
              class Community::Member::Rating < ActiveRecord::Base
                belongs_to :member
              end
              EOF
              runner.prepare('app/models/community/member/rating.rb', content)
              content = <<-EOF
              class Community::Member < ActiveRecord::Base
                has_many :ratings
              end
              EOF
              runner.prepare('app/models/community/member.rb', content)
              runner.after_prepare
              model_associations = Prepares.model_associations
              expect(model_associations.get_association('Community::Member::Rating', 'member')).to eq({ 'meta' => 'belongs_to', 'class_name' => 'Community::Member' })
              expect(model_associations.get_association('Community::Member', 'ratings')).to eq({ 'meta' => 'has_many', 'class_name' => 'Community::Member::Rating' })
            end
          end
        end

        context 'mongoid embeds' do
          it 'should parse embeds_many' do
            content = <<-EOF
            class Person
              include Mongoid::Document
              embeds_many :addresses
            end
            EOF
            runner.prepare('app/models/person.rb', content)
            model_associations = Prepares.model_associations
            expect(model_associations.get_association('Person', 'addresses')).to eq({ 'meta' => 'embeds_many', 'class_name' => 'Address' })
          end

          it 'should parse embeds_one' do
            content = <<-EOF
            class Lush
              include Mongoid::Document
              embeds_one :whiskey, class_name: "Drink", inverse_of: :alcoholic
            end
            EOF
            runner.prepare('app/models/lush.rb', content)
            model_associations = Prepares.model_associations
            expect(model_associations.get_association('Lush', 'whiskey')).to eq({ 'meta' => 'embeds_one', 'class_name' => 'Drink' })
          end

          it 'should parse embedded_in' do
            content = <<-EOF
            class Drink
              include Mongoid::Document
              embedded_in :alcoholic, class_name: "Lush", inverse_of: :whiskey
            end
            EOF
            runner.prepare('app/models/drink.rb', content)
            model_associations = Prepares.model_associations
            expect(model_associations.get_association('Drink', 'alcoholic')).to eq({ 'meta' => 'embedded_in', 'class_name' => 'Lush' })
          end
        end

        context 'mongomapper many/one' do
          it 'should parse one' do
            content = <<-EOF
            class Employee
              include MongoMapper::Document
              one :desk
            end
            EOF
            runner.prepare('app/models/employee.rb', content)
            model_associations = Prepares.model_associations
            expect(model_associations.get_association('Employee', 'desk')).to eq({ 'meta' => 'one', 'class_name' => 'Desk' })
          end

          it 'should parse many' do
            content = <<-EOF
            class Tree
              include MongoMapper::Document
              many :birds
            end
            EOF
            runner.prepare('app/models/tree.rb', content)
            model_associations = Prepares.model_associations
            expect(model_associations.get_association('Tree', 'birds')).to eq({ 'meta' => 'many', 'class_name' => 'Bird' })
          end
        end
      end

      context 'methods' do
        it 'should parse model methods' do
          content = <<-EOF
          class Post < ActiveRecord::Base
            def save; end
            def find; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          methods = Prepares.model_methods
          expect(methods.get_methods('Post').map(&:method_name)).to eq(['save', 'find'])
        end

        it 'should parse model methods with access control' do
          content = <<-EOF
          class Post < ActiveRecord::Base
            def save; end
            def find; end
            protected
            def create_or_update; end
            private
            def find_by_sql; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          methods = Prepares.model_methods
          expect(methods.get_methods('Post').map(&:method_name)).to eq(['save', 'find', 'create_or_update', 'find_by_sql'])
          expect(methods.get_methods('Post', 'public').map(&:method_name)).to eq(['save', 'find'])
          expect(methods.get_methods('Post', 'protected').map(&:method_name)).to eq(['create_or_update'])
          expect(methods.get_methods('Post', 'private').map(&:method_name)).to eq(['find_by_sql'])
        end

        it 'should parse model methods with module ::' do
          content = <<-EOF
          class Admin::Blog::Post < ActiveRecord::Base
            def save; end
            def find; end
          end
          EOF
          runner.prepare('app/models/admin/blog/post.rb', content)
          methods = Prepares.model_methods
          expect(methods.get_methods('Admin::Blog::Post').map(&:method_name)).to eq(['save', 'find'])
        end

        it 'should parse model methods with module' do
          content = <<-EOF
          module Admin
            module Blog
              class Post < ActiveRecord::Base
                def save; end
                def find; end
              end
            end
          end
          EOF
          runner.prepare('app/models/admin/blog/post.rb', content)
          methods = Prepares.model_methods
          expect(methods.get_methods('Admin::Blog::Post').map(&:method_name)).to eq(['save', 'find'])
        end

        it 'should not add methods from module' do
          content = <<-EOF
            class Model < ActiveRecord::Base
            end
          EOF
          runner.prepare('app/models/model.rb', content)
          content = <<-EOF
            module Mixin
              def mixed_method
              end
            end
          EOF
          runner.prepare('app/models/mixins/mixin.rb', content)
          methods = Prepares.model_methods
          expect(methods.get_methods('Model')).to be_empty
        end
      end

      context 'scope' do
        it 'should treat named_scope as method' do
          content = <<-EOF
          class Post < ActiveRecord::Base
            named_scope :active, conditions: {active: true}
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          methods = Prepares.model_methods
          expect(methods.get_methods('Post').map(&:method_name)).to eq(['active'])
        end

        it 'should treat scope as method' do
          content = <<-EOF
          class Post < ActiveRecord::Base
            scope :active, where(active: true)
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          methods = Prepares.model_methods
          expect(methods.get_methods('Post').map(&:method_name)).to eq(['active'])
        end
      end

      context 'alias' do
        it 'should treat alias as method' do
          content = <<-EOF
          class Post < ActiveRecord::Base
            alias :new :old
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          methods = Prepares.model_methods
          expect(methods.get_methods('Post').map(&:method_name)).to eq(['new'])
        end

        it 'should treat alias_method as method' do
          content = <<-EOF
          class Post < ActiveRecord::Base
            alias_method :new, :old
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          methods = Prepares.model_methods
          expect(methods.get_methods('Post').map(&:method_name)).to eq(['new'])
        end

        it 'should treat alias_method_chain as method' do
          content = <<-EOF
          class Post < ActiveRecord::Base
            alias_method_chain :method, :feature
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          methods = Prepares.model_methods
          expect(methods.get_methods('Post').map(&:method_name)).to eq(['method_with_feature', 'method'])
        end
      end

      context 'attributes' do
        it 'should parse mongoid field' do
          content = <<-EOF
          class Post
            include Mongoid::Document
            field :title
            field :tags, type: Array
            field :comments_count, type: Integer
            field :deleted_at, type: DateTime
            field :active, type: Boolean
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          model_attributes = Prepares.model_attributes
          expect(model_attributes.get_attribute_type('Post', 'title')).to eq('String')
          expect(model_attributes.get_attribute_type('Post', 'tags')).to eq('Array')
          expect(model_attributes.get_attribute_type('Post', 'comments_count')).to eq('Integer')
          expect(model_attributes.get_attribute_type('Post', 'deleted_at')).to eq('DateTime')
          expect(model_attributes.get_attribute_type('Post', 'active')).to eq('Boolean')
        end

        it 'should parse mongomapper field' do
          content = <<-EOF
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
          runner.prepare('app/models/post.rb', content)
          model_attributes = Prepares.model_attributes
          expect(model_attributes.get_attribute_type('Post', 'first_name')).to eq('String')
          expect(model_attributes.get_attribute_type('Post', 'last_name')).to eq('String')
          expect(model_attributes.get_attribute_type('Post', 'age')).to eq('Integer')
          expect(model_attributes.get_attribute_type('Post', 'born_at')).to eq('Time')
          expect(model_attributes.get_attribute_type('Post', 'active')).to eq('Boolean')
          expect(model_attributes.get_attribute_type('Post', 'fav_colors')).to eq('Array')
        end
      end

      context 'no error' do
        it 'should raised for finder_sql option' do
          content = <<-EOF
          class EventSubscription < ActiveRecord::Base
            has_many :event_notification_template, finder_sql: ?
          end
          EOF
          content = content.sub('?', '\'SELECT event_notification_templates.* from event_notification_templates where event_type_id=#{event_type_id} and delivery_method_id=#{delivery_method_id}\'')
          expect { runner.prepare('app/models/event_subscription.rb', content) }.not_to raise_error
        end
      end
    end
  end
end
