require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::MoveModelLogicIntoModelCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::MoveModelLogicIntoModelCheck.new)
  end
  
  it "should move model logic into model" do
    content = <<-EOF
    class PostsController < ApplicationController
      
      def publish
        @post = Post.find(params[:id])
        @post.update_attributes(:is_published, true)
        @post.approved_by = current_user
        if @post.created_at > Time.now - 7.days
          @post.popular = 100
        else
          @post.popular = 0
        end
      end
      
      redirect_to post_url(@post)
    end
    EOF
    @runner.check('app/controllers/posts_controller.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
    errors[0].to_s.should == "app/controllers/posts_controller.rb:3 - move model logic into model (@post called_count > 4)"
  end

  it "should not move model logic into model with simple model calling" do
    content = <<-EOF
    class PostsController < ApplicationController

      def publish
        @post = Post.find(params[:id])
        @post.update_attributes(:is_published, true)
        @post.approved_by = current_user
      end

      redirect_to post_url(@post)
    end
    EOF
    @runner.check('app/controllers/posts_controller.rb', content)
    errors = @runner.errors
    errors.should be_empty
  end
end
