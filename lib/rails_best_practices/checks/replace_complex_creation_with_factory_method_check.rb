require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a controller file to make sure that complex model creation should not exist in controller, move it to model factory method
    #
    # Implementation: check the count of variable attribute assignment calling before saving, 
    # if more than defined attribute assignment count, then it's a complex creation.
    class ReplaceComplexCreationWithFactoryMethodCheck < Check
      
      def interesting_nodes
        [:defn]
      end
      
      def interesting_files
        CONTROLLER_FILES
      end
      
      def initialize(options = {})
        super()
        @attrasgn_count = options['attribute_assignment_count'] || 2
      end
      
      def evaluate_start(node)
        @variables = {}
        node.recursive_children do |child|
          case child.node_type
          when :attrasgn
            attribute_assignment(child)
          when :call
            call_assignment(child)
          else
          end
        end
        @variables = nil
      end
      
      private
      
      def attribute_assignment(node)
        variable = node.subject
        return if variable.nil? or ![:lvar, :ivar].include? node.subject.node_type
        @variables[variable] ||= 0
        @variables[variable] += 1
      end
      
      def call_assignment(node)
        if node.message == :save
          variable = node.subject
          add_error "replace complex creation with factory method (#{variable.to_ruby} attribute_assignment_count > #{@attrasgn_count})" if @variables[variable] > @attrasgn_count
        end
      end
    end
  end
end
