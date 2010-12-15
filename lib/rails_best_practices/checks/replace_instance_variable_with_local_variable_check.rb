# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a partail view file to make sure there is no instance variable.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/27-replace-instance-variable-with-local-variable.
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   check all instance variable in partial view files,
    #   if exist, then they should be replaced with local variable
    class ReplaceInstanceVariableWithLocalVariableCheck < Check

      def interesting_review_nodes
        [:ivar]
      end

      def interesting_review_files
        PARTIAL_VIEW_FILES
      end

      # check ivar node in partial view file,
      # it is an instance variable, and should be replaced with local variable.
      def review_start_ivar(node)
        add_error "replace instance variable with local variable"
      end
    end
  end
end
