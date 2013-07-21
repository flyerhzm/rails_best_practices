# encoding: utf-8
module RailsBestPractices
  module Reviews
    # review a controller file to make sure to use model association instead of foreign key id assignment.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/2-use-model-association.
    #
    # Implementation:
    #
    # Review process:
    #   check model define nodes in all controller files,
    #   if there is an attribute assignment node with message xxx_id=,
    #   and after it, there is a call node with message "save" or "save!",
    #   and the receivers of attribute assignment node and call node are the same,
    #   then model association should be used instead of xxx_id assignment.
    class UseModelAssociationReview < Review
      interesting_nodes :def
      interesting_files CONTROLLER_FILES
      url "http://rails-bestpractices.com/posts/2-use-model-association"

      # check method define nodes to see if there are some attribute assignments that can use model association instead.
      #
      # it will check attribute assignment node with message xxx_id=, and call node with message "save" or "save!"
      #
      # 1. if there is an attribute assignment node with message xxx_id=,
      #    then remember the receiver of attribute assignment node.
      # 2. after assignment, if there is a call node with message "save" or "save!",
      #    and the receiver of call node is one of the receiver of attribute assignment node,
      #    then the attribute assignment should be replaced by using model association.
      add_callback :start_def do |node|
        @assignments = {}
        node.recursive_children do |child|
          case child.sexp_type
          when :assign
            attribute_assignment(child)
          when :call
            call_assignment(child)
          else
          end
        end
        @assignments = nil
      end

      private
        # check an attribute assignment node, if its message is xxx_id,
        # then remember the receiver of the attribute assignment in @assignments.
        def attribute_assignment(node)
          if node.left_value.message.to_s =~ /_id$/
            receiver = node.left_value.receiver.to_s
            @assignments[receiver] = true
          end
        end

        # check a call node with message "save" or "save!",
        # if the receiver of call node exists in @assignments,
        # then the attribute assignment should be replaced by using model association.
        def call_assignment(node)
          if ["save", "save!"].include? node.message.to_s
            receiver = node.receiver.to_s
            add_error "use model association (for #{receiver})" if @assignments[receiver]
          end
        end
    end
  end
end
