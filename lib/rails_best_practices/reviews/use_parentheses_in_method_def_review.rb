# encoding: utf-8
module RailsBestPractices
  module Reviews
    # Check if method definition has parentheses around parameters.
    #
    # Review process:
    #   check def node in all files,
    #   if params node with values, but not wrapped by paren node,
    #   then it should use parentheses around parameters.
    class UseParenthesesInMethodDefReview < Review
      interesting_nodes :def
      interesting_files ALL_FILES

      # check def node to see if parameters are wrapped by parentheses.
      add_callback :start_def do |node|
        if no_parentheses_around_parameters?(node) && has_parameters?(node)
          add_error("use parentheses around parameters in method definitions")
        end
      end

      protected

        def no_parentheses_around_parameters?(def_node)
          :parent != def_node[2][0]
        end

        def has_parameters?(def_node)
          :params == def_node[2][0] && !def_node[2][1..-1].compact.empty?
        end
    end
  end
end
