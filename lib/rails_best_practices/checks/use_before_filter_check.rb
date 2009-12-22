require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a controller file to make sure to use before_filter to remove duplicate call in different action.
    #
    # Implementation: Check all methods' first call, if they are duplicate, then should use before_filter.
    class UseBeforeFilterCheck < Check

      def interesting_nodes
        [:class]
      end

      def interesting_files
        CONTROLLER_FILES
      end

      def evaluate_start(node)
        @methods = {}
        node.grep_nodes({:node_type => :defn}).each { |method_node| remember_method(method_node) }
        @methods.each do |first_call, method_nodes|
          if method_nodes.size > 1
            add_error "use before_filter for #{method_nodes.collect{|method_node| method_node.message_name}.join(',')}", 
              node.file, method_nodes.collect{|method_node| method_node.line}.join(',')
          end
        end
      end

      private

      def remember_method(method_node)
        first_call = method_node.body[1]
        unless first_call == s(:nil)
          @methods[first_call] ||= []
          @methods[first_call] << method_node
        end
      end
    end
  end
end
