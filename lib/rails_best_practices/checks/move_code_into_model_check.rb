# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a view file to make sure there is no complex logic call for model.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/25-move-code-into-model.
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   check if there are multiple method calls or attribute assignments apply to one subject,
    #   and the subject is a local variable or instance variable,
    #   then they should be moved into model.
    class MoveCodeIntoModelCheck < Check

      def interesting_review_nodes
        [:if]
      end

      def interesting_review_files
        VIEW_FILES
      end

      def initialize(options={})
        super()
        @use_count = options['use_count'] || 2
      end

      # check if node to see whose conditional statementnodes contain multiple call nodes with same subject who is a local variable or instance variable.
      #
      # it will check every call and attrasgn nodes in the conditional statement nodes.
      #
      # if there are multiple call and attrasgn nodes who have the same subject,
      # and the subject is a local variable or an instance variable,
      # then the conditional statement nodes should be moved into model.
      def review_start_if(node)
        node.conditional_statement.grep_nodes(:node_type => [:call, :attrasgn]) { |child_node| remember_variable_use_count(child_node) }

        variable_use_count.each do |variable_node, count|
          add_error "move code into model (#{variable_node} use_count > #{@use_count})", variable_node.file, variable_node.line if count > @use_count
        end

        reset_variable_use_count
      end
    end
  end
end
