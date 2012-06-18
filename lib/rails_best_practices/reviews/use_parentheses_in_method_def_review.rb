# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    class UseParenthesesInMethodDefReview < Review
      interesting_nodes :def
      interesting_files ALL_FILES

      def start_def(node)
        if no_parentheses_around_parameters? node
          if method_has_parameters? node
            add_error("use parentheses around parameters in method definitions")
          end
        end
      end

      protected
        def no_parentheses_around_parameters?(node)
          not node[2][0] == :paren
        end

        def method_has_parameters?(node)
          not node[2][1..-1].to_a.compact.empty?
        end
    end
  end
end
