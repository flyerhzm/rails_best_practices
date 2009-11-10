require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a controller file to make sure that model logic should not exist in controller, move it into a model.
    #
    # Implementation: check the count of method calling of a model, 
    # if it is more than defined called count, then it contains model logic.
    class MoveModelLogicIntoModelCheck < Check
      
      def interesting_nodes
        [:defn]
      end
      
      def interesting_files
        CONTROLLER_FILES
      end

      def initialize(options = {})
        super()
        @called_count = options['called_count'] || 4
      end

      def evaluate_start(node)
        @variables = {}
        node.recursive_children do |child|
          case child.node_type
          when :attrasgn, :call
            call_node(child)
          end
        end
        
        @variables.each do |variable, count|
          add_error "move model logic into model (#{variable.to_ruby} called_count > #{@called_count})" if count > @called_count
        end
        @variables = nil
      end

      private
      
      def call_node(node)
        variable = node.subject
        return if variable.nil? or ![:lvar, :ivar].include? node.subject.node_type
        @variables[variable] ||= 0
        @variables[variable] += 1
      end
    end
  end
end
