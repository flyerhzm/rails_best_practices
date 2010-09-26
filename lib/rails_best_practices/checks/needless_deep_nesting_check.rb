# encoding: utf-8
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
        @counter = 0
        @nested_count = options['nested_count'] || 2
      end
      
      def evaluate_start(node)
        check_nested_count(node)
      end

      private
        def check_nested_count(node)
          if :iter == node.node_type
            check_for_rails3(node)
          elsif :resources == node.message and node.subject
            check_for_rails2(node)
          end
        end

        def check_for_rails3(node)
          nested_count_for_rails3(node)
        end

        def check_for_rails2(node)
          if node.subject == s(:call, nil, :map, s(:arglist))
            @counter = 0
          else
            @counter += 1
            add_error "needless deep nesting (nested_count > #{@nested_count})" if @counter >= @nested_count
          end
        end

        def nested_count_for_rails3(node)
          if :iter == node.node_type and :resources == node.subject.message and !node.message
            @counter += 1
            nested_count_for_rails3(node[3])
            @counter -= 1
          elsif :block == node.node_type
            node.children.each do |child_node|
              if :resources == child_node.message and nil == child_node.subject and @counter + 1 > @nested_count
                add_error "needless deep nesting (nested_count > #{@nested_count})", child_node.file, child_node.line
              end
            end
          elsif :call == node.node_type and :resources == node.message
            add_error "needless deep nesting (nested_count > #{@nested_count})", node.file, node.line if @counter + 1 > @nested_count
          end
        end
    end
  end
end
