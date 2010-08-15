require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check config/routes.rb to make sure not to use too deep nesting routes.
    #
    # Implementation: check nested route count, if more than nested_count, then it is needless deep nesting.
    class NeedlessDeepNestingCheck < Check
      
      def interesting_nodes
        [:call, :iter]
      end

      def interesting_files
        /config\/routes.rb/
      end

      def initialize(options = {})
        super()
        @nested_count = options['nested_count'] || 2
      end
      
      def evaluate_start(node)
        check_nested_count(node)
      end

      private
        def check_nested_count(node)
          if :iter == node.node_type
            check_for_rails3(node)
          elsif :resources == node.message
            check_for_rails2(node)
          end
        end

        def check_for_rails3(node)
          nodes = node.grep_nodes(:message => :resources).delete_if {|node| nil != node.subject}
          deepest_node = nodes.last
          if nodes.size > @nested_count
            add_error "needless deep nesting (nested_count > #{@nested_count})", deepest_node.file, deepest_node.line
          end
        end

        def check_for_rails2(node)
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
