# encoding: utf-8
# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review a view file to make sure there is no complex logic call for model.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/07/24/move-code-into-model/
    #
    # Implementation:
    #
    # Review process:
    #   check if, unless, elsif there are multiple method calls or attribute assignments apply to one receiver,
    #   and the receiver is a variable, then they should be moved into model.
    class MoveCodeIntoModelReview < Review
      interesting_nodes :if, :unless, :elsif, :ifop, :if_mod, :unless_mod
      interesting_files VIEW_FILES
      url 'https://rails-bestpractices.com/posts/2010/07/24/move-code-into-model/'

      def initialize(options={})
        super(options)
        @use_count = options['use_count'] || 2
      end

      # check if node to see whose conditional statementnodes contain multiple call nodes with same receiver who is a variable.
      #
      # it will check every call and assignment nodes in the conditional statement nodes.
      #
      # if there are multiple call and assignment nodes who have the same receiver,
      # and the receiver is a variable, then the conditional statement nodes should be moved into model.
      add_callback :start_if, :start_unless, :start_elsif, :start_ifop, :start_if_mod, :start_unless_mod do |node|
        node.conditional_statement.grep_nodes(sexp_type: :call) { |child_node| remember_variable_use_count(child_node) }

        variable_use_count.each do |variable_node, count|
          add_error "move code into model (#{variable_node} use_count > #{@use_count})" if count > @use_count
        end

        reset_variable_use_count
      end
    end
  end
end
