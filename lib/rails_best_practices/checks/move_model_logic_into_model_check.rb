# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a controller file to make sure that complex model logic should not exist in controller, should be moved into a model.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/7-move-model-logic-into-the-model.
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   check all method defines in the controller files,
    #   if there are multiple method calls or attribute assignments apply to one subject,
    #   and the subject is a local variable or an instance variable,
    #   then they are complex model logic, and they should be moved into model.
    class MoveModelLogicIntoModelCheck < Check
      def url
        "http://rails-bestpractices.com/posts/7-move-model-logic-into-the-model"
      end

      def interesting_review_nodes
        [:defn]
      end

      def interesting_review_files
        CONTROLLER_FILES
      end

      def initialize(options = {})
        super()
        @use_count = options['use_count'] || 4
      end

      # check method define node to see if there are multiple method calls and attribute assignments (more than @use_count defined) on one local variable or instance varialbe in review process.
      #
      # it will check every call and attrasgn nodes,
      # if there are multiple call and attrasgn nodes who have the same subject,
      # and the subject is a local variable or an instance variable,
      # then these method calls and attribute assignments should be moved into model.
      def review_start_defn(node)
        node.grep_nodes(:node_type => [:call, :attrasgn]) do |child_node|
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
