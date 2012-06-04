require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe MoveModelLogicIntoModelReview do
      let(:runner) { Core::Runner.new(reviews: MoveModelLogicIntoModelReview.new) }

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

            redirect_to post_url(@post)
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        runner.should have(1).errors
        runner.errors[0].to_s.should == "app/controllers/posts_controller.rb:2 - move model logic into model (@post use_count > 4)"
      end

      it "should not move model logic into model with simple model calling" do
        content = <<-EOF
        class PostsController < ApplicationController
          def publish
            @post = Post.find(params[:id])
            @post.update_attributes(:is_published, true)
            @post.approved_by = current_user

            redirect_to post_url(@post)
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        runner.should have(0).errors
      end

      it "should not move model logic into model with self calling" do
        content = <<-EOF
        class PostsController < ApplicationController
          def publish
            self.step1
            self.step2
            self.step3
            self.step4
            self.step5
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        runner.should have(0).errors
      end
    end
  end
end
