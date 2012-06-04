# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review a controller file to make sure that complex model logic should not exist in controller, should be moved into a model.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/7-move-model-logic-into-the-model.
    #
    # Implementation:
    #
    # Review process:
    #   check all method defines in the controller files,
    #   if there are multiple method calls apply to one subject,
    #   and the subject is a variable,
    #   then they are complex model logic, and they should be moved into model.
    class MoveModelLogicIntoModelReview < Review
      interesting_nodes :def
      interesting_files CONTROLLER_FILES

      def url
        "http://rails-bestpractices.com/posts/7-move-model-logic-into-the-model"
      end

      def initialize(options = {})
        super()
        @use_count = options['use_count'] || 4
      end

      # check method define node to see if there are multiple method calls on one varialbe.
      #
      # it will check every call nodes,
      # if there are multiple call nodes who have the same subject,
      # and the subject is a variable,
      # then these method calls and attribute assignments should be moved into model.
      def start_def(node)
        node.grep_nodes(sexp_type: [:call, :assign]) do |child_node|
          remember_variable_use_count(child_node)
        end

        variable_use_count.each do |variable_node, count|
          add_error "move model logic into model (#{variable_node} use_count > #{@use_count})" if count > @use_count
        end

        reset_variable_use_count
      end
    end
  end
end
