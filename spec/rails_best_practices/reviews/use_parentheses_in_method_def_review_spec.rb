# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe UseParenthesesInMethodDefReview do
      let(:runner) { Core::Runner.new(reviews: described_class.new) }

      it 'finds missing parentheses' do
        content = <<-EOF
        class PostsController < ApplicationController
          def edit foo, bar
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq(
          'app/controllers/posts_controller.rb:2 - use parentheses around parameters in method definitions'
        )
      end
      it 'finds parentheses with no error' do
        content = <<-EOF
        class PostsController < ApplicationController
          def edit(foo, bar)
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(0)
      end
      it 'does not throw an error without parameters' do
        content = <<-EOF
        class PostsController < ApplicationController
          def edit
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'does not check ignored files' do
        runner = Core::Runner.new(reviews: described_class.new(ignored_files: /posts_controller/))
        content = <<-EOF
        class PostsController < ApplicationController
          def edit foo, bar
          end
        end
        EOF
        runner.review('app/controllers/posts_controller.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
