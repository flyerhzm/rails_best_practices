# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review model files to make sure not use default_scope
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2013/06/15/default_scope-is-evil/
    #
    # Implementation:
    #
    # Review process:
    #   check all command node to see if its message is default_scope
    class DefaultScopeIsEvilReview < Review
      interesting_nodes :command
      interesting_files MODEL_FILES
      url 'https://rails-bestpractices.com/posts/2013/06/15/default_scope-is-evil/'

      # check all command nodes' message
      add_callback :start_command do |node|
        if 'default_scope' == node.message.to_s
          add_error 'default_scope is evil'
        end
      end
    end
  end
end
