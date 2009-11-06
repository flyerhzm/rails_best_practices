require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a model creation to make sure using model association.
    #
    # Implementation: 
    # 1. check :attrasgn, if xxx_id is assigned to a variable, set the value of the assigned variable to true.
    # 2. check :call, if call message :save and caller is included in variables, add error.
    class UseModelAssociationCheck < Check
      
      def interesting_nodes
        [:defn]
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
        if node.message.to_s =~ /_id=$/
          variable = node.subject[1]
          @variables[variable] = true
        end
      end
      
      def call_assignment(node)
        if node.message == :save
          variable = node.subject[1]
          add_error "use model association (for #{node.subject.to_ruby})" if @variables[variable]
        end
      end
    end
  end
end
