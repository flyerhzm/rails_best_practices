require File.join(File.dirname(__FILE__) + '/../../spec_helper')

describe RailsBestPractices::Checks::UseScopeAccessCheck do
  before(:each) do
    @runner = RailsBestPractices::Core::Runner.new(RailsBestPractices::Checks::UseScopeAccessCheck.new)
  end
  
  context "if" do
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
      @runner.check('app/controllers/posts_controller.rb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "app/controllers/posts_controller.rb:7 - use scope access"
    end

    it "shoud use scope access by comparing with id" do
      content = <<-EOF
      class PostsController < ApplicationController

        def edit
          @post = Post.find(params[:id])

          if @post.user_id != current_user.id
            flash[:warning] = 'Access Denied'
            redirect_to posts_url
          end
        end
      end
      EOF
      @runner.check('app/controllers/posts_controller.rb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "app/controllers/posts_controller.rb:7 - use scope access"
    end

    it "shoud use scope access with current_user ==" do
      content = <<-EOF
      class PostsController < ApplicationController

        def edit
          @post = Post.find(params[:id])

          if current_user != @post.user
            flash[:warning] = 'Access Denied'
            redirect_to posts_url
          end
        end
      end
      EOF
      @runner.check('app/controllers/posts_controller.rb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "app/controllers/posts_controller.rb:7 - use scope access"
    end

    it "shoud use scope access by current_user.id ==" do
      content = <<-EOF
      class PostsController < ApplicationController

        def edit
          @post = Post.find(params[:id])

          if current_user.id != @post.user_id
            flash[:warning] = 'Access Denied'
            redirect_to posts_url
          end
        end
      end
      EOF
      @runner.check('app/controllers/posts_controller.rb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "app/controllers/posts_controller.rb:7 - use scope access"
    end
  end

  context "unless" do
    it "shoud use scope access" do
      content = <<-EOF
      class PostsController < ApplicationController

        def edit
          @post = Post.find(params[:id])

          unless @post.user == current_user
            flash[:warning] = 'Access Denied'
            redirect_to posts_url
          end
        end
      end
      EOF
      @runner.check('app/controllers/posts_controller.rb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "app/controllers/posts_controller.rb:6 - use scope access"
    end

    it "shoud use scope access by comparing with id" do
      content = <<-EOF
      class PostsController < ApplicationController

        def edit
          @post = Post.find(params[:id])

          unless @post.user_id == current_user.id
            flash[:warning] = 'Access Denied'
            redirect_to posts_url
          end
        end
      end
      EOF
      @runner.check('app/controllers/posts_controller.rb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "app/controllers/posts_controller.rb:6 - use scope access"
    end

    it "shoud use scope access with current_user ==" do
      content = <<-EOF
      class PostsController < ApplicationController

        def edit
          @post = Post.find(params[:id])

          unless current_user == @post.user
            flash[:warning] = 'Access Denied'
            redirect_to posts_url
          end
        end
      end
      EOF
      @runner.check('app/controllers/posts_controller.rb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "app/controllers/posts_controller.rb:6 - use scope access"
    end

    it "shoud use scope access by current_user.id ==" do
      content = <<-EOF
      class PostsController < ApplicationController

        def edit
          @post = Post.find(params[:id])

          unless current_user.id == @post.user_id
            flash[:warning] = 'Access Denied'
            redirect_to posts_url
          end
        end
      end
      EOF
      @runner.check('app/controllers/posts_controller.rb', content)
      errors = @runner.errors
      errors.should_not be_empty
      errors[0].to_s.should == "app/controllers/posts_controller.rb:6 - use scope access"
    end
    
    it "should no error in use_scope_access_check" do
      content = <<-EOF
      class CommentsController < ApplicationController
      
        def add_comment
          @current_user = User.find_by_id(session[:user_id])
          @id = params[:post_id]
          @error = ""
          if (@text = params[:text]) == ""
            @error = "Please enter a comment!"
          else
            @comment = Comment.create_object(@text,  @id, @current_user.id)
          end
          unless @comment
            @error = "Comment could not be saved."
          end
        end
      end
      EOF
      @runner.check('app/controllers/comments_controller.rb', content)
    end
  end
end
