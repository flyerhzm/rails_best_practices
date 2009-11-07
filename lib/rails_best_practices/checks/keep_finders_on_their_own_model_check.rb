require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a model to make sure finders are on their own model.
    #
    # Implementation: check if :find is called by other model.
    class KeepFindersOnTheirOwnModelCheck < Check
      
      def interesting_nodes
        [:call]
      end

      def interesting_files
        /models\/.*rb/
      end

      def evaluate_start(node)
        add_error "keep finders on their own model" if others_finder?(node)
      end

      private

      def others_finder?(node)
        node.message == :find and node.subject.node_type == :call
      end
    end
  end
end
