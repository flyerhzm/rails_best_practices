# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module InlineDisables
    describe InlineDisable do
      let(:runner) { Core::Runner.new(reviews: Reviews::MoveModelLogicIntoModelReview.new) }

      it 'moves model logic into model' do
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
        runner.inline_disable('app/controllers/posts_controller.rb', content)

        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq(
          'app/controllers/posts_controller.rb:2 - move model logic into model (@post use_count > 4)'
        )
      end

      it 'is no error is output' do
        content = <<-EOF
        class PostsController < ApplicationController
          def publish # rails_best_practices:disable MoveModelLogicIntoModelCheck
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
        runner.inline_disable('app/controllers/posts_controller.rb', content)

        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
