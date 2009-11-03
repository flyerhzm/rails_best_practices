require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a controller to make sure use scope to 
    class UseScopeAccessCheck < Check
      
      def interesting_nodes
        [:if]
      end
      
      def interesting_files
        /_controller.rb$/
      end
      
      def evaluate_start(node)
        add_error "use scope access" if current_user_redirect(node)
      end
      
      private
      
      def current_user_redirect(node)
        condition_node = node.call
        condition_node.message == :== and condition_node.arguments.call.message == :current_user and node.false_node.method_body.any? {|n| n.message == :redirect_to}
      end
      
    end
  end
end