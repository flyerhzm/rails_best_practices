require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::UseBeforeFilterCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::UseBeforeFilterCheck.new)
  end
  
  it "should use before_filter" do
    content = <<-EOF
    class PostsController < ApplicationController

      def show
        @post = current_user.posts.find(params[:id])
      end

      def edit
        @post = current_user.posts.find(params[:id])
      end

      def update
        @post = current_user.posts.find(params[:id])
        @post.update_attributes(params[:post])
      end

      def destroy
        @post = current_user.posts.find(params[:id])
        @post.destroy
      end

    end
    EOF
    @runner.check('app/controllers/posts_controller.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/controllers/posts_controller.rb:3,7,11,16 - use before_filter for show,edit,update,destroy"
  end
  
  it "should not use before_filter" do
    content = <<-EOF
    class PostsController < ApplicationController
      before_filter :find_post, :only => [:show, :edit, :update, :destroy]

      def update
        @post.update_attributes(params[:post])
      end

      def destroy
        @post.destroy
      end

      protected

      def find_post
        @post = current_user.posts.find(params[:id])
      end
    end
    EOF
    @runner.check('app/controllers/posts_controller.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end

  it "should not use before_filter by nil" do
    content = <<-EOF
    class PostsController < ApplicationController

      def show
      end

      def edit
      end

      def update
      end

      def destroy
      end

    end
    EOF
    @runner.check('app/controllers/posts_controller.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
