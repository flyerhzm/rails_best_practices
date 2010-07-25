require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a view file to make sure there is no complex logic call for model.
    #
    # Implementation: Check if a local variable or instance variable called greater than 2 times in if or unless conditional statement, then it should more code into model.
    class MoveCodeIntoModelCheck < Check

      def interesting_nodes
        [:if, :unless]
      end

      def interesting_files
        VIEW_FILES
      end

      def evaluate_start(node)
        @variables = {}
        node.conditional_statement.grep_nodes(:node_type => :call).each { |call_node| remember_call(call_node) }
        check_errors
      end

      private

      def check_errors
        @variables.each do |node, count|
          add_error "move code into model (#{node.to_ruby})" if count > 2
        end
      end

      def remember_call(call_node)
        variable_node = variable(call_node)
        if variable_node
          @variables[variable_node] ||= 0
          @variables[variable_node] += 1
        end
      end

      def variable(call_node)
        while call_node.subject.node_type == :call
          call_node = call_node.subject
        end
        subject_node = call_node.subject
        if [:ivar, :lvar].include?(subject_node.node_type) and subject_node[1] != :_erbout
          subject_node
        else
          nil
        end
      end
    end
  end
end
