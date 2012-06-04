# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review a view file to make sure there is no complex logic call for model.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/25-move-code-into-model.
    #
    # Implementation:
    #
    # Review process:
    #   check if, unless, elsif there are multiple method calls or attribute assignments apply to one subject,
    #   and the subject is a variable, then they should be moved into model.
    class MoveCodeIntoModelReview < Review
      interesting_nodes :if, :unless, :elsif
      interesting_files VIEW_FILES

      def url
        "http://rails-bestpractices.com/posts/25-move-code-into-model"
      end

      def initialize(options={})
        super()
        @use_count = options['use_count'] || 2
      end

      # check if node to see whose conditional statementnodes contain multiple call nodes with same subject who is a variable.
      #
      # it will check every call and assignment nodes in the conditional statement nodes.
      #
      # if there are multiple call and assignment nodes who have the same subject,
      # and the subject is a variable, then the conditional statement nodes should be moved into model.
      def start_if(node)
        node.conditional_statement.grep_nodes(sexp_type: :call) { |child_node| remember_variable_use_count(child_node) }

        variable_use_count.each do |variable_node, count|
          add_error "move code into model (#{variable_node} use_count > #{@use_count})" if count > @use_count
        end

        reset_variable_use_count
      end

      alias_method :start_unless, :start_if
      alias_method :start_elsif, :start_if
    end
  end
end
