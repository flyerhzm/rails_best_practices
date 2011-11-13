require 'spec_helper'

describe RailsBestPractices::Reviews::RemoveUnusedMethodsInModelsReview do
  let(:runner) { RailsBestPractices::Core::Runner.new(
    :prepares => [RailsBestPractices::Prepares::ModelPrepare.new, RailsBestPractices::Prepares::ControllerPrepare.new],
    :reviews => RailsBestPractices::Reviews::RemoveUnusedMethodsInModelsReview.new({'except_methods' => ['set_cache']})
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
      runner.on_complete
      runner.should have(1).errors
      runner.errors[0].to_s.should == "app/models/post.rb:4 - remove unused methods (Post#find_by_sql)"
    end

    it "should not remove unused methods with except_methods" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        def set_cache; end
      end
      EOF
      runner.prepare('app/models/post.rb', content)
      runner.review('app/models/post.rb', content)
      runner.on_complete
      runner.should have(0).errors
    end

    it "should not remove unused methods with var_ref" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        def find;
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
      runner.on_complete
      runner.should have(0).errors
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
      runner.on_complete
      runner.should have(0).errors
    end

    it "should not remove unused method with command" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        def fetch
          get(:position => 'first')
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
      runner.on_complete
      runner.should have(0).errors
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
      runner.on_complete
      runner.should have(0).errors
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
      runner.on_complete
      runner.should have(0).errors
    end

    it "should not remove unused method with validation condition" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        validates_uniqueness_of :login, :if => :email_blank?
        private
        def email_blank?; end
      end
      EOF
      runner.prepare('app/models/post.rb', content)
      runner.review('app/models/post.rb', content)
      runner.on_complete
      runner.should have(0).errors
    end

    it "should not remove unused method with aasm" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        aasm_state :accepted, :enter => [:update_datetime]
        private
        def update_datetime; end
      end
      EOF
      runner.prepare('app/models/post.rb', content)
      runner.review('app/models/post.rb', content)
      runner.on_complete
      runner.should have(0).errors
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
      runner.on_complete
      runner.should have(0).errors
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
      runner.on_complete
      runner.should have(1).errors
      runner.errors[0].to_s.should == "app/models/post.rb:2 - remove unused methods (Post#fetch)"
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
      runner.on_complete
      runner.should have(0).errors
    end

    it "should not remove unused methods for attribute assignment" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        def user=(user); end
      end
      EOF
      runner.prepare('app/models/post.rb', content)
      runner.review('app/models/post.rb', content)
      runner.on_complete
      runner.should have(0).errors
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
      runner.on_complete
      runner.should have(0).errors
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
      runner.on_complete
      runner.should have(0).errors
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
      runner.on_complete
      runner.should have(1).errors
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
      runner.on_complete
      runner.should have(1).errors
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
      runner.on_complete
      runner.should have(1).errors
      runner.errors[0].to_s.should == "app/models/post.rb:3 - remove unused methods (Post#test)"
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
      runner.on_complete
      runner.should have(0).errors
    end
  end

  context "named_scope" do
    it "should not remove unused named_scope" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        named_scope :active, :conditions => {:active => true}
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
      runner.on_complete
      runner.should have(0).errors
    end

    it "should remove unused named_scope" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        named_scope :active, :conditions => {:active => true}
      end
      EOF
      runner.prepare("app/models/post.rb", content)
      runner.review("app/models/post.rb", content)
      runner.on_complete
      runner.should have(1).errors
      runner.errors[0].to_s.should == "app/models/post.rb:2 - remove unused methods (Post#active)"
    end
  end

  context "scope" do
    it "should not remove unused scope" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        scope :active, where(:active => true)
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
      runner.on_complete
      runner.should have(0).errors
    end

    it "should remove unused named_scope" do
      content =<<-EOF
      class Post < ActiveRecord::Base
        scope :active, where(:active => true)
      end
      EOF
      runner.prepare("app/models/post.rb", content)
      runner.review("app/models/post.rb", content)
      runner.on_complete
      runner.should have(1).errors
      runner.errors[0].to_s.should == "app/models/post.rb:2 - remove unused methods (Post#active)"
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
      runner.on_complete
      runner.should have(0).errors
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
      runner.on_complete
      runner.should have(0).errors
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
      runner.on_complete
      runner.should have(0).errors
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
      runner.on_complete
      runner.should have(0).errors
    end
  end
end
