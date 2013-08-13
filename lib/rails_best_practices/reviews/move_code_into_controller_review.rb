# encoding: utf-8
module RailsBestPractices
  module Reviews
    # Review a view file to make sure there is no finder, finder should be moved to controller.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/24-move-code-into-controller.
    #
    # Implementation:
    #
    # Review process:
    #   only check all view files to see if there are finders, then the finders should be moved to controller.
    class MoveCodeIntoControllerReview < Review
      interesting_nodes :method_add_arg, :assign
      interesting_files VIEW_FILES
      url "http://rails-bestpractices.com/posts/24-move-code-into-controller"

      FINDERS = %w(find all first last)

      # check method_add_arg nodes.
      #
      # if the receiver of the method_add_arg node is a constant,
      # and the message of the method_add_arg node is one of the find, all, first and last,
      # then it is a finder and should be moved to controller.
      add_callback :start_method_add_arg do |node|
        add_error "move code into controller" if finder?(node)
      end

      # check assign nodes.
      #
      # if the receiver of the right value node is a constant,
      # and the message of the right value node is one of the find, all, first and last,
      # then it is a finder and should be moved to controller.
      add_callback :start_assign do |node|
        add_error "move code into controller", node.file, node.right_value.line_number if finder?(node.right_value)
      end

      private
        # check if the node is a finder call node.
        def finder?(node)
          node.receiver.const? && FINDERS.include?(node.message.to_s)
        end
    end
  end
end
