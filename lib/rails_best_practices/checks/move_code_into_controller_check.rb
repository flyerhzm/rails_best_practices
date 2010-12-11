# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a view file to make sure there is no finder, finder should be moved to controller.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/24-move-code-into-controller.
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   only check all view files to see if there are finders, then the finders should be moved to controller.
    class MoveCodeIntoControllerCheck < Check

      FINDERS = [:find, :all, :first, :last]

      def interesting_review_nodes
        [:call]
      end

      def interesting_review_files
        VIEW_FILES
      end

      # check call nodes in review process.
      #
      # if the subject of the call node is a constant,
      # and the message of the call node is one of the :find, :all, :first and :last,
      # then it is a finder and should be moved to controller.
      def review_start_call(node)
        add_error "move code into controller" if finder?(node)
      end

      private
        # check if the node is a finder call node.
        # e.g. the following call node is a finder
        #
        #     s(:call,
        #       s(:const, :Post),
        #       :find,
        #       s(:arglist, s(:lit, :all))
        #     )
        def finder?(node)
          :const == node.subject.node_type && FINDERS.include?(node.message)
        end
    end
  end
end
