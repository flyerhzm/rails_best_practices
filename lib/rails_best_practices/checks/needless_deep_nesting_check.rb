require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check config/routes.rb to make sure not to use too deep nesting routes.
    #
    # Implementation: check nested route count, if more than nested_count, then it is needless deep nesting.
    class NeedlessDeepNestingCheck < Check
      
      def interesting_nodes
        [:call]
      end

      def interesting_files
        /config\/routes.rb/
      end

      def initialize(options = {})
        super()
        @nested_count = options['nested_count'] || 2
      end
      
      def evaluate_start(node)
        if node.message == :resources
          if node.subject == s(:call, nil, :map, s(:arglist))
            @counter = 0
          else
            @counter += 1
            add_error "needless deep nesting (nested_count > #{@nested_count})" if @counter >= @nested_count
          end
        end
      end
    end
  end
end