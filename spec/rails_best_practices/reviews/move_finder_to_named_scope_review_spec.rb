require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe MoveFinderToNamedScopeReview do
      let(:runner) { Core::Runner.new(reviews: MoveFinderToNamedScopeReview.new) }

      it "should move finder to named_scope" do
        content = <<-EOF
        class PostsController < ActionController::Base
          def index
            @public_posts = Post.find(:all, conditions: { state: 'public' },
                                            limit: 10,
                                            order: 'created_at desc')

            @draft_posts  = Post.find(:all, conditions: { state: 'draft' },
                                            limit: 10,
                                            order: 'created_at desc')
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        runner.should have(2).errors
        runner.errors[0].to_s.should == "app/controllers/posts_controller.rb:3 - move finder to named_scope"
        runner.errors[1].to_s.should == "app/controllers/posts_controller.rb:7 - move finder to named_scope"
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
        runner.review('app/controllers/posts_controller.rb', content)
        runner.should have(0).errors
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
        runner.review('app/controllers/posts_controller.rb', content)
        runner.should have(0).errors
      end

      it "should not review model file" do
        content = <<-EOF
        class Post < ActiveRecord::Base
          def published
            Post.find(:all, conditions: { state: 'public' },
                            limit: 10, order: 'created_at desc')
          end

          def published
            Post.find(:all, conditions: { state: 'draft' },
                            limit: 10, order: 'created_at desc')
          end
        end
        EOF
        runner.review('app/model/post.rb', content)
        runner.should have(0).errors
      end
    end
  end
end
