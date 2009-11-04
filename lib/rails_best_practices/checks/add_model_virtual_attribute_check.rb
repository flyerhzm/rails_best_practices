require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a controller to make sure adding a model virual attribute to simplify model creation.
    #
    # Implementation: check arguments of params#[]=, if they have duplicated arguments, then the model may need to add a model virtual attribute.
    class AddModelVirtualAttributeCheck < Check
      
      def interesting_nodes
        [:defn]
      end
      
      def interesting_files
        /_controller.rb$/
      end

      def evaluate_start(node)
        add_error("add model virtual attribute") if params_dup?(node)
      end
      
      private
      
      def params_dup?(node)
        params_nodes = node.grep_nodes({:subject => s(:call, nil, :params, s(:arglist)), :message => :[]})
        params_arguments = params_nodes.collect(&:arguments)
        !params_arguments.dups.empty?
      end
    end
  end
end