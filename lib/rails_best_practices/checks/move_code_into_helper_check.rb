require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a view file to make sure there is no complex options_for_select message call.
    #
    # Implementation: Check if first argument of options_for_select is an array and contains more than two nodes, then it should be moved into helper.
    class MoveCodeIntoHelperCheck < Check
    
      def interesting_nodes
        [:call]
      end
    
      def interesting_files
        VIEW_FILES
      end

      def initialize(options = {})
        super()
        @array_count = options['array_count'] || 3
      end

      def evaluate_start(node)
        add_error "move code into helper (array_count >= #{@array_count})" if complex_select_options?(node)
      end
      
      private
      
      def complex_select_options?(node)
        :options_for_select == node.message and :array == node.arguments[1].node_type and node.arguments[1].size > @array_count
      end
    end
  end
end