# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review a controller file to make sure that complex model creation should not exist in
    # controller, should be replaced with factory method.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/07/21/replace-complex-creation-with-factory-method/
    #
    # Implementation:
    #
    # Review process:
    #   check all method defines in the controller files,
    #   if there are multiple attribute assignments apply to one receiver,
    #   and the receiver is a variable,
    #   and after them there is a call node with message "save" or "save!",
    #   then these attribute assignments are complex creation, should be replaced with factory method.
    class ReplaceComplexCreationWithFactoryMethodReview < Review
      interesting_nodes :def
      interesting_files CONTROLLER_FILES
      url 'https://rails-bestpractices.com/posts/2010/07/21/replace-complex-creation-with-factory-method/'

      def initialize(options = {})
        super(options)
        @assigns_count = options['attribute_assignment_count'] || 2
      end

      # check method define node to see if there are multiple assignments, more than
      # @assigns_count, on one variable before save.
      #
      # it wll check every attrasgn nodes in method define node,
      # if there are multiple assign nodes who have the same receiver,
      # and the receiver is a variable,
      # and after them, there is a call node with message "save" or "save!",
      # then these attribute assignments are complex creation, should be replaced with factory method.
      add_callback :start_def do |node|
        node.recursive_children do |child_node|
          case child_node.sexp_type
          when :assign
            if :"." == child_node.receiver[2]
              remember_variable_use_count(child_node)
            end
          when :call
            check_variable_save(child_node)
          end
        end
        reset_variable_use_count
      end

      private

        # check the call node to see if it is with message "save" or "save!",
        # and the count attribute assignment on the receiver of the call node is greater than @assign_count defined,
        # then it is a complex creation, should be replaced with factory method.
      def check_variable_save(node)
        if ['save', 'save!'].include? node.message.to_s
          variable = node.receiver.to_s
          if variable_use_count[variable].to_i > @assigns_count
            hint = "#{variable} attribute_assignment_count > #{@assigns_count}"
            add_error "replace complex creation with factory method (#{hint})"
          end
        end
      end
    end
  end
end
