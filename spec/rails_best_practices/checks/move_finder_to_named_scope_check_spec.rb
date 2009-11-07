require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::MoveFinderToNamedScopeCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::MoveFinderToNamedScopeCheck.new)
  end
  
  it "should move finder to named_scope" do
    content = <<-EOF
    class PostsController < ActionController::Base

      def index
        @public_posts = Post.find(:all, :conditions => { :state => 'public' },
                                        :limit => 10,
                                        :order => 'created_at desc')

        @draft_posts  = Post.find(:all, :conditions => { :state => 'draft' },
                                        :limit => 10,
                                        :order => 'created_at desc')
      end
    end
    EOF
    @runner.check('app/controllers/posts_controller.rb', content)
    errors = @runner.errors
    errors.size.should == 2
    errors[0].to_s.should == "app/controllers/posts_controller.rb:4 - move finder to named_scope"
    errors[1].to_s.should == "app/controllers/posts_controller.rb:8 - move finder to named_scope"
  end
  
  it "should not move simple finder" do
    content = <<-EOF
    class PostsController < ActionController::Base

      def index
        @all_posts = Post.find(:all)
        @another_all_posts = Post.all
        @first_post = Post.find(:first)
        @another_first_post = Post.first
        @last_post = Post.find(:last)
        @another_last_post = Post.last
      end
    end
    EOF
    @runner.check('app/controllers/posts_controller.rb', content)
    @runner.errors.should be_empty
  end
  
  it "should not move namd_scope" do
    content = <<-EOF
    class PostsController < ActionController::Base

      def index
        @public_posts = Post.published
        @draft_posts  = Post.draft
      end
    end
    EOF
    @runner.check('app/controllers/posts_controller.rb', content)
    @runner.errors.should be_empty
  end
  
  it "should not check model file" do
    content = <<-EOF
    class Post < ActiveRecord::Base
      
      def published
        Post.find(:all, :conditions => { :state => 'public' },
                        :limit => 10, :order => 'created_at desc')
      end

      def published
        Post.find(:all, :conditions => { :state => 'draft' },
                        :limit => 10, :order => 'created_at desc')
      end
                          
    end
    EOF
    @runner.check('app/model/post.rb', content)
    @runner.errors.should be_empty
    
  end
end
