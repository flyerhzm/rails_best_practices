require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a controller to make sure adding a model virual attribute to simplify model creation.
    #
    # Implementation: check arguments of params#[]= before calling save, 
    # if they have duplicated arguments, then the model may need to add a model virtual attribute.
    class AddModelVirtualAttributeCheck < Check
      
      def interesting_nodes
        [:defn]
      end
      
      def interesting_files
        CONTROLLER_FILES
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
        arguments_node = nil
        node.arguments.recursive_children do |child|
          if :[] == child.message
            arguments_node = child
            break
          end
        end
        return if variable.nil? or arguments_node.nil?
        @variables[variable] ||= []
        @variables[variable] << {:message => node.message, :arguments => arguments_node}
      end
      
      def call_assignment(node)
        if node.message == :save
          variable = node.subject
          add_error "add model virtual attribute (for #{node.subject.to_ruby})" if params_dup?(@variables[variable].collect {|h| h[:arguments]})
        end
      end
      
      def params_dup?(nodes)
        return false if nodes.nil?
        !nodes.dups.empty?
      end
    end
  end
end
