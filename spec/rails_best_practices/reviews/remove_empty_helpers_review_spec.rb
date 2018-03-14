# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe RemoveEmptyHelpersReview do
      let(:runner) { Core::Runner.new(reviews: RemoveEmptyHelpersReview.new) }

      it 'should remove empty helpers' do
        content =<<-EOF
        module PostsHelper
        end
        EOF
        runner.review('app/helpers/posts_helper.rb', content)
        expect(runner.errors.size).to eq(1)
        expect(runner.errors[0].to_s).to eq('app/helpers/posts_helper.rb:1 - remove empty helpers')
      end

      it 'should not remove empty helpers' do
        content =<<-EOF
        module PostsHelper
          def post_link(post)
            post_path(post)
          end
        end
        EOF
        runner.review('app/helpers/posts_helper.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not remove empty application_helper' do
        content =<<-EOF
        module ApplicationHelper
        end
        EOF
        runner.review('app/helpers/application_helper.rb', content)
        expect(runner.errors.size).to eq(0)
      end

      it 'should not check ignored files' do
        runner = Core::Runner.new(reviews: RemoveEmptyHelpersReview.new(ignored_files: /posts_helper/))
        content =<<-EOF
        module PostsHelper
        end
        EOF
        runner.review('app/helpers/posts_helper.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
