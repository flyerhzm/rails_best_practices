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
        /_controller.rb$/
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
        return if variable.nil?
        @variables[variable] ||= []
        @variables[variable] << {:message => node.message, :arguments => node.arguments}
      end
      
      def call_assignment(node)
        if node.message == :save
          variable = node.subject
          add_error "add model virtual attribute (for #{node.subject.to_ruby})" if params_dup?(@variables[variable].collect {|h| h[:arguments] })
        end
      end
      
      def params_dup?(nodes)
        return false if nodes.nil?
        params_nodes = nodes.collect {|node| node.grep_nodes({:subject => s(:call, nil, :params, s(:arglist)), :message => :[]}).first}.compact
        params_arguments = params_nodes.collect(&:arguments)
        !params_arguments.dups.empty?
      end
    end
  end
end
