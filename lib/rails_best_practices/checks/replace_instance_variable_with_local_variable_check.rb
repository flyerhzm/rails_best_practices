require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a partail view file to make sure there is no instance variable.
    #
    # Implementation: Check all instance variable, if exists, then it should be replaced with local variable
    class ReplaceInstanceVariableWithLocalVariableCheck < Check
      
      def interesting_nodes
        [:ivar]
      end
      
      def interesting_files
        PARTIAL_VIEW_FILES
      end
      
      def evaluate_start(node)
        add_error "replace instance variable with local variable"
      end
    end
  end
end
