require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a view file to make sure there is no finder.
    #
    # Implementation: Check if view file contains finder, then the code should move to controller.
    class MoveCodeIntoControllerCheck < Check
      
      FINDER = [:find, :all, :first, :last]
      
      def interesting_nodes
        [:call]
      end
      
      def interesting_files
        VIEW_FILES
      end
      
      def evaluate_start(node)
        add_error "move code into controller" if finder?(node)
      end
      
      private

      def finder?(node)
        node.subject.node_type == :const && FINDER.include?(node.message)
      end
    end
  end
end
