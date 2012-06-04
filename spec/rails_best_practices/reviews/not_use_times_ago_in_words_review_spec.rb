require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe NotUseTimeAgoInWordsReview do
      let(:runner) { Core::Runner.new(reviews: NotUseTimeAgoInWordsReview.new) }

      describe "time_ago_in_words" do
        it "should not use in views" do
          content =<<-EOF
          <%= time_ago_in_words(post.created_at) %>
          EOF
          runner.review('app/views/posts/show.html.erb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/views/posts/show.html.erb:1 - not use time_ago_in_words"
        end

        it "should not use in helpers" do
          content =<<-EOF
          def timeago
            content_tag(:p, time_ago_in_words(post.created_at))
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/helpers/posts_helper.rb:2 - not use time_ago_in_words"
        end
      end

      describe "distance_of_time_in_words_to_now" do
        it "should not use in views" do
          content =<<-EOF
          <%= distance_of_time_in_words_to_now(post.created_at) %>
          EOF
          runner.review('app/views/posts/show.html.erb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/views/posts/show.html.erb:1 - not use time_ago_in_words"
        end

        it "should not use in helpers" do
          content =<<-EOF
          def timeago
            content_tag(:p, distance_of_time_in_words_to_now(post.created_at))
          end
          EOF
          runner.review('app/helpers/posts_helper.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "app/helpers/posts_helper.rb:2 - not use time_ago_in_words"
        end
      end
    end
  end
end
