require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe RemoveUnusedMethodsInModelsReview do
      let(:runner) { Core::Runner.new(
        prepares: Prepares::ModelPrepare.new,
        reviews: RemoveUnusedMethodsInModelsReview.new({'except_methods' => ["*#set_cache"]})
      ) }

      context "private" do
        it "should remove unused methods" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def find; end
            private
            def find_by_sql; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          content =<<-EOF
          class PostsController < ApplicationController
            def get
              Post.new.find
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/models/post.rb:4 - remove unused methods (Post#find_by_sql)")
        end

        it "should not remove unused methods with except_methods" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def set_cache; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused methods with var_ref" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def find
              find_by_sql
            end
            private
            def find_by_sql; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          content =<<-EOF
          class PostsController < ApplicationController
            def get
              Post.new.find
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused methods with callback" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            after_save :expire_cache
            private
            def expire_cache; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused method with command" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def fetch
              get(position: 'first')
            end
            private
            def get(options={}); end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          content =<<-EOF
          class PostsController < ApplicationController
            def get
              Post.new.fetch
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused method with call" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def conditions
              self.build_conditions({})
            end
            private
            def build_conditions(conditions={}); end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          content =<<-EOF
          class PostsController < ApplicationController
            def get
              Post.new.conditions
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused method with message" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def save
              transaction true do
                self.update
              end
            end
            private
            def transaction(force); end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          content =<<-EOF
          class PostsController < ApplicationController
            def create
              Post.new.save
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused method with validation condition" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            validates_uniqueness_of :login, if: :email_blank?
            private
            def email_blank?; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused method with aasm" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            aasm_state :accepted, enter: [:update_datetime]
            private
            def update_datetime; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused method with initialize" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            private
            def initialize; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end
      end

      context "public" do
        it "should remove unused methods" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def fetch; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/models/post.rb:2 - remove unused methods (Post#fetch)")
        end

        it "should not remove unused methods" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def fetch; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          content =<<-EOF
          class PostsController < ApplicationController
            def show
              @post.fetch
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused methods for attribute assignment" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def user=(user); end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused methods for try" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def find(user_id); end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          content =<<-EOF
          class PostsController < ApplicationController
            def find
              Post.new.try(:find, current_user.id)
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused methods for send" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def find(user_id); end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          content =<<-EOF
          class PostsController < ApplicationController
            def find
              Post.new.send(:find, current_user.id)
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should remove unused methods for send string_embexpre" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def find_first; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          content =<<-EOF
          class PostsController < ApplicationController
            def find
              type = "first"
              Post.new.send("find_\#{type}")
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(1)
        end

        it "should remove unused methods for send variable" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def first; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          content =<<-EOF
          class PostsController < ApplicationController
            def find
              type = "first"
              Post.new.send(type)
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(1)
        end
      end

      context "protected" do
        it "should not remove unused methods" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            protected
            def test; end
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          content =<<-EOF
          class PostsController < ApplicationController
            def test
              Post.new.test
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/models/post.rb:3 - remove unused methods (Post#test)")
        end

        it "should not remove unused methods" do
          post_content =<<-EOF
          class Post < ActiveRecord::Base
            protected
            def test; end
          end
          EOF
          blog_post_content =<<-EOF
          class BlogPost < Post
            def play
              test
            end
          end
          EOF
          runner.prepare("app/models/post.rb", post_content)
          runner.prepare("app/models/blog_post.rb", blog_post_content)
          runner.review("app/models/post.rb", post_content)
          runner.review("app/models/blog_post.rb", blog_post_content)
          content =<<-EOF
          class BlogPostsController < ApplicationController
            def play
              BlogPost.new.play
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end
      end

      context "named_scope" do
        it "should not remove unused named_scope" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            named_scope :active, conditions: {active: true}
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          content =<<-EOF
          class PostsController < ApplicationController
            def index
              @posts = Post.active
            end
          end
          EOF
          runner.review("app/controllers/posts_controller.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should remove unused named_scope" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            named_scope :active, conditions: {active: true}
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/models/post.rb:2 - remove unused methods (Post#active)")
        end
      end

      context "scope" do
        it "should not remove unused scope" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            scope :active, where(active: true)
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          content =<<-EOF
          class PostsController < ApplicationController
            def index
              @posts = Post.active
            end
          end
          EOF
          runner.review("app/controllers/posts_controller.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should remove unused named_scope" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            scope :active, where(active: true)
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/models/post.rb:2 - remove unused methods (Post#active)")
        end
      end

      context "alias" do
        it "should not remove unused method with alias" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def old; end
            alias new old
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          content =<<-EOF
          class PostsController < ApplicationController
            def show
              @post.new
            end
          end
          EOF
          runner.review("app/controllers/posts_controller.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

         it "should not remove unused method with symbol alias" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def old; end
            alias :new :old
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          content =<<-EOF
          class PostsController < ApplicationController
            def show
              @post.new
            end
          end
          EOF
          runner.review("app/controllers/posts_controller.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused method with alias_method" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def old; end
            alias_method :new, :old
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          content =<<-EOF
          class PostsController < ApplicationController
            def show
              @post.new
            end
          end
          EOF
          runner.review("app/controllers/posts_controller.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused method with alias_method_chain" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def method_with_feature; end
            alias_method_chain :method, :feature
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          content =<<-EOF
          class PostsController < ApplicationController
            def show
              @post.method
            end
          end
          EOF
          runner.review("app/controllers/posts_controller.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end
      end

      context "methods hash" do
        it "should not remove unused method with methods hash" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def to_xml(options = {})
              super options.merge(exclude: :visible, methods: [:is_discussion_conversation])
            end

            def is_discussion_conversation; end
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end
      end

      context "callbacks" do
        it "should not remove unused method" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            before_save :init_columns
            after_destroy :remove_dependencies

            protected
              def init_columns; end
              def remove_dependencies; end
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end
      end

      context "validates" do
        it "should not remove unused method" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            validate :valid_birth_date

            protected
              def valid_birth_date; end
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused method for validate_on_create and validate_on_update" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            validate_on_create :valid_email
            validate_on_update :valid_birth_date

            protected
              def valid_email; end
              def valid_birth_date; end
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused methods for to_param" do
          content =<<-EOF
          class Post < ActiveRecord::Base
            def to_param
              id
            end
          end
          EOF
          runner.prepare("app/models/post.rb", content)
          runner.review("app/models/post.rb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end
      end

      context "helper method" do
        it "should not remove unused method for coommand_call collection_select" do
          content =<<-EOF
          class Category < ActiveRecord::Base
            def indented_name; end
          end
          EOF
          runner.prepare("app/models/category.rb", content)
          runner.review("app/models/category.rb", content)
          content =<<-EOF
          <%= f.collection_select :parent_id, Category.all_hierarchic(except: @category), :id, :indented_name, {include_blank: true} %>
          EOF
          runner.review("app/views/categories/_form.html.erb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused method for command collection_select" do
          content =<<-EOF
          class Category < ActiveRecord::Base
            def indented_name; end
          end
          EOF
          runner.prepare("app/models/category.rb", content)
          runner.review("app/models/category.rb", content)
          content =<<-EOF
          <%= collection_select :category, :parent_id, Category.all_hierarchic(except: @category), :id, :indented_name, {include_blank: true} %>
          EOF
          runner.review("app/views/categories/_form.html.erb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end

        it "should not remove unused method for options_from_collection_for_select" do
          content =<<-EOF
          class Category < ActiveRecord::Base
            def indented_name; end
          end
          EOF
          runner.prepare("app/models/category.rb", content)
          runner.review("app/models/category.rb", content)
          content =<<-EOF
          <%= select_tag 'category', options_from_collection_for_select(Category.all_hierachic(except: @category), :id, :indented_name) %>
          EOF
          runner.review("app/views/categories/_form.html.erb", content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
        end
      end

      it "should not remove unused methods for rabl view" do
        content =<<-EOF
        class User
          def first_name; end
          def last_name; end
        end
        EOF
        runner.prepare("app/models/user.rb", content)
        runner.review("app/models/user.rb", content)
        content =<<-EOF
        node :full_name do |u|
          u.first_name + " " + u.last_name
        end
        EOF
        runner.review("app/views/users/show.json.rabl", content)
        runner.after_review
        expect(runner.errors.size).to eq(0)
      end

      it "should not skip :call as call message" do
        content =<<-EOF
        module DateRange
          RANGES = lambda {
            last_month = {
              'range' => lambda { [date_from_time.(31.days.ago), date_from_time.(Time.now)] },
              'value' => 'last_month',
              'label' => 'Last month'}
          }[]
        end
        EOF
        runner.prepare("app/mixins/date_range.rb", content)
        runner.review("app/mixins/date_range.rb", content)
      end

      it "should not check ignored files" do
        runner = Core::Runner.new(prepares: Prepares::ModelPrepare.new,
                                  reviews: RemoveUnusedMethodsInModelsReview.new(except_methods: [], ignored_files: /post/))

          content =<<-EOF
          class Post < ActiveRecord::Base
            def find; end
            private
            def find_by_sql; end
          end
          EOF
          runner.prepare('app/models/post.rb', content)
          runner.review('app/models/post.rb', content)
          content =<<-EOF
          class PostsController < ApplicationController
            def get
              Post.new.find
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          runner.after_review
          expect(runner.errors.size).to eq(0)
      end
    end
  end
end
