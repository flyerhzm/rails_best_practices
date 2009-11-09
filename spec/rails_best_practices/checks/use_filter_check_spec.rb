require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::UseFilterCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::UseFilterCheck.new)
  end
  
  it "should use filter" do
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
    errors[0].to_s.should == "app/controllers/posts_controller.rb:1 - use filter for @post = current_user.posts.find(params[:id]) in show,edit,update,destroy"
  end
  
  it "should not use filter" do
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
end
