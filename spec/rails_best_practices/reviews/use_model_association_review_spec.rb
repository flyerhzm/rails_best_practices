# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe UseModelAssociationReview do
      let(:runner) { Core::Runner.new(reviews: UseModelAssociationReview.new) }

      it 'should use model association for instance variable' do
        content = <<-EOF
        class PostsController < ApplicationController
          def create
            @post = Post.new(params[:post])
            @post.user_id = current_user.id
            @post.save
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/controllers/posts_controller.rb:2 - use model association (for @post)')
      end

      it 'should not use model association without association assign' do
        content = <<-EOF
        class PostsController < ApplicationController
          def create
            @post = Post.new(params[:post])
            @post.save
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should use model association for local variable' do
        content = <<-EOF
        class PostsController < ApplicationController
          def create
            post = Post.new(params[:post])
            post.user_id = current_user.id
            post.save
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/controllers/posts_controller.rb:2 - use model association (for post)')
      end

      it 'should not use model association' do
        content = <<-EOF
        class PostsController < ApplicationController
          def create
            post = current_user.posts.buid(params[:post])
            post.save
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not check ignored files' do
        runner = Core::Runner.new(reviews: UseModelAssociationReview.new(ignored_files: /posts_controller/))
        content = <<-EOF
        class PostsController < ApplicationController
          def create
            @post = Post.new(params[:post])
            @post.user_id = current_user.id
            @post.save
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
