# encoding: utf-8
# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review view and helper files to make sure not use time_ago_in_words or distance_of_time_in_words_to_now.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2012/02/10/not-use-time_ago_in_words/
    #
    # Implementation:
    #
    # Review process:
    #   check all fcall node to see if its message is time_ago_in_words and distance_of_time_in_words_to_now
    class NotUseTimeAgoInWordsReview < Review
      interesting_nodes :fcall
      interesting_files VIEW_FILES, HELPER_FILES
      url 'https://rails-bestpractices.com/posts/2012/02/10/not-use-time_ago_in_words/'

      # check fcall node to see if its message is time_ago_in_words or distance_of_time_in_words_to_now
      add_callback :start_fcall do |node|
        if 'time_ago_in_words' == node.message.to_s || 'distance_of_time_in_words_to_now' == node.message.to_s
          add_error 'not use time_ago_in_words'
        end
      end
    end
  end
end
