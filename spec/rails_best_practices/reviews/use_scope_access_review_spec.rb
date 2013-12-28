require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe UseScopeAccessReview do
      let(:runner) { Core::Runner.new(reviews: UseScopeAccessReview.new) }

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
          runner.review('app/controllers/posts_controller.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/controllers/posts_controller.rb:5 - use scope access")
        end

        it "shoud use scope access with if in one line" do
          content = <<-EOF
          class PostsController < ApplicationController
            def edit
              @post = Post.find(params[:id])

              redirect_to posts_url if @post.user != current_user
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/controllers/posts_controller.rb:5 - use scope access")
        end

        it "shoud use scope access with '? :'" do
          content = <<-EOF
          class PostsController < ApplicationController
            def edit
              @post = Post.find(params[:id])

              @post.user != current_user ? redirect_to(posts_url) : render
            end
          end
          EOF
          runner.review('app/controllers/posts_controller.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/controllers/posts_controller.rb:5 - use scope access")
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
          runner.review('app/controllers/posts_controller.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/controllers/posts_controller.rb:5 - use scope access")
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
          runner.review('app/controllers/posts_controller.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/controllers/posts_controller.rb:5 - use scope access")
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
          runner.review('app/controllers/posts_controller.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/controllers/posts_controller.rb:5 - use scope access")
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
          runner.review('app/controllers/posts_controller.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/controllers/posts_controller.rb:5 - use scope access")
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
          runner.review('app/controllers/posts_controller.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/controllers/posts_controller.rb:5 - use scope access")
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
          runner.review('app/controllers/posts_controller.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/controllers/posts_controller.rb:5 - use scope access")
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
          runner.review('app/controllers/posts_controller.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("app/controllers/posts_controller.rb:5 - use scope access")
        end

        it "should no error in use_scope_access_review" do
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
          runner.review('app/controllers/comments_controller.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it "should not check ignored files" do
          runner = Core::Runner.new(reviews: UseScopeAccessReview.new(ignored_files: /posts_controller/))
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
          runner.review('app/controllers/posts_controller.rb', content)
          expect(runner.errors.size).to eq(0)
        end
      end
    end
  end
end
