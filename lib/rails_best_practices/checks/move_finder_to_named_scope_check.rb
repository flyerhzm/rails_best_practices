require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a controller file to make sure finder is simple.
    #
    # Complex finder in controller is a code smell, use namd_scope instead.
    #
    # Implementation: check method :find, :all, :first, :last with hash parameters.
    class MoveFinderToNamedScopeCheck < Check
      
      FINDER = [:find, :all, :first, :last]
      
      def interesting_nodes
        [:call]
      end
      
      def interesting_files
        CONTROLLER_FILES
      end

      def evaluate_start(node)
        add_error "move finder to named_scope" if finder?(node)
      end
      
      private
      
      def finder?(node)
        node.subject.node_type == :const && FINDER.include?(node.message) && node.arguments.children.any? {|node| node.node_type == :hash}
      end
    end
  end
end