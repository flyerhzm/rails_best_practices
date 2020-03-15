# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe NotUseTimeAgoInWordsReview do
      let(:runner) { Core::Runner.new(reviews: described_class.new) }

      describe 'time_ago_in_words' do
        it 'does not use in views' do
          content = <<-EOF
          <%= time_ago_in_words(post.created_at) %>
          EOF
          runner.review('app/views/posts/show.html.erb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq('app/views/posts/show.html.erb:1 - not use time_ago_in_words')
        end

        it 'does not use in helpers' do
          content = <<-EOF
          def timeago
            content_tag(:p, time_ago_in_words(post.created_at))
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq('app/helpers/posts_helper.rb:2 - not use time_ago_in_words')
        end
      end

      describe 'distance_of_time_in_words_to_now' do
        it 'does not use in views' do
          content = <<-EOF
          <%= distance_of_time_in_words_to_now(post.created_at) %>
          EOF
          runner.review('app/views/posts/show.html.erb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq('app/views/posts/show.html.erb:1 - not use time_ago_in_words')
        end

        it 'does not use in helpers' do
          content = <<-EOF
          def timeago
            content_tag(:p, distance_of_time_in_words_to_now(post.created_at))
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq('app/helpers/posts_helper.rb:2 - not use time_ago_in_words')
        end
      end

      it 'does not check ignored files' do
        runner = Core::Runner.new(reviews: described_class.new(ignored_files: /posts_helper/))
        content = <<-EOF
          def timeago
            content_tag(:p, time_ago_in_words(post.created_at))
          end
        EOF
        runner.review('app/helpers/posts_helper.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
