require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::UseScopeAccessCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::UseScopeAccessCheck.new)
  end
  
  it "shoud use scope access" do
    content = <<-EOF
    class PostsController < ApplicationController
      
      def edit
        @post = Post.find(params[:id])
        
        if @post.user != current_user
          flash[:warning] = 'Access Denied'
          redirect_to posts_url
        end
      end
    end
    EOF
    @runner.check('app/controller/posts_controller.rb', content)
    errors = @runner.errors
    errors.should_not be_empty
  end
end