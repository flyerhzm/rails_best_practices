# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review all code to make sure we either check the return value of "destroy"
    # or use "destroy!"
    #
    # Review process:
    #   Track which nodes are used by 'if', 'unless', '&&' nodes etc. as we pass them by.
    #   Check all "save" calls to check the return value is used by a node we have visited.
    class CheckDestroyReturnValueReview < Review
      include Classable
      interesting_nodes :call, :command_call, :method_add_arg, :if, :ifop, :elsif, :unless, :if_mod, :unless_mod, :assign, :binary
      interesting_files ALL_FILES

      add_callback :start_if, :start_ifop, :start_elsif, :start_unless, :start_if_mod, :start_unless_mod do |node|
        @used_return_value_of = node.conditional_statement.all_conditions
      end

      add_callback :start_assign do |node|
        @used_return_value_of = node.right_value
      end

      add_callback :start_binary do |node|
        # Consider anything used in an expression like "A or B" as used
        if %w[&& || and or].include?(node[2].to_s)
          all_conditions = node.all_conditions
          # if our current binary is a subset of the @used_return_value_of
          # then don't overwrite it
          already_included = @used_return_value_of &&
                             (all_conditions - @used_return_value_of).empty?

          @used_return_value_of = node.all_conditions unless already_included
        end
      end

      def return_value_is_used?(node)
        return false unless @used_return_value_of

        node == @used_return_value_of or @used_return_value_of.include?(node)
      end

      def model_classnames
        @model_classnames ||= models.map(&:to_s)
      end

      add_callback :start_call, :start_command_call, :start_method_add_arg do |node|
        unless @already_checked == node
          message = node.message.to_s
          if message.eql? 'destroy'
            unless return_value_is_used? node
              add_error "check '#{message}' return value or use '#{message}!'"
            end
          end
          if node.sexp_type == :method_add_arg
            @already_checked = node[1]
          end
        end
      end
    end
  end
end
