require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a controller to make sure using scope access
    #
    # Implementation: simply check if or unless compare with current_user or current_user.id and there is a redirect_to message in if or unless block
    class UseScopeAccessCheck < Check
      
      def interesting_nodes
        [:if, :unless]
      end
      
      def interesting_files
        CONTROLLER_FILES
      end
      
      def evaluate_start(node)
        add_error "use scope access" if current_user_redirect?(node)
      end
      
      private
      
      def current_user_redirect?(node)
        condition_node = node.call
        
        condition_node.message == :== and 
        (current_user?(condition_node.arguments.call) or current_user?(condition_node.subject)) and 
        (node.false_node.body.any? {|n| n.message == :redirect_to} or node.true_node.method_body.any? {|n| n.message == :redirect_to})
      end
      
      def current_user?(call_node)
        call_node.node_type == :call and (call_node.message == :current_user or (call_node.subject.message == :current_user and call_node.message == :id))
      end
      
    end
  end
end
