# encoding: utf-8
module RailsBestPractices
  module Reviews
    # Review a controller file to make sure that complex model logic should not exist in controller, should be moved into a model.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/07/21/move-model-logic-into-the-model/
    #
    # Implementation:
    #
    # Review process:
    #   check all method defines in the controller files,
    #   if there are multiple method calls apply to one receiver,
    #   and the receiver is a variable,
    #   then they are complex model logic, and they should be moved into model.
    class MoveModelLogicIntoModelReview < Review
      interesting_nodes :def
      interesting_files CONTROLLER_FILES
      url "https://rails-bestpractices.com/posts/2010/07/21/move-model-logic-into-the-model/"

      def initialize(options = {})
        super(options)
        @use_count = options['use_count'] || 4
      end

      # check method define node to see if there are multiple method calls on one varialbe.
      #
      # it will check every call nodes,
      # if there are multiple call nodes who have the same receiver,
      # and the receiver is a variable,
      # then these method calls and attribute assignments should be moved into model.
      add_callback :start_def do |node|
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
