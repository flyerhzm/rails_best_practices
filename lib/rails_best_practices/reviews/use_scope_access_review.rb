# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review a controller to make sure to use scope access instead of manually checking current_user and redirect.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/07/20/use-scope-access/
    #
    # Implementation:
    #
    # Review process:
    #   check all if nodes to see
    #
    #   if they are compared with current_user or current_user.id,
    #   and there is redirect_to method call in if block body,
    #   then it should be replaced by using scope access.
    class UseScopeAccessReview < Review
      interesting_nodes :if, :unless, :elsif, :ifop, :if_mod, :unless_mod
      interesting_files CONTROLLER_FILES
      url 'https://rails-bestpractices.com/posts/2010/07/20/use-scope-access/'

      # check if node.
      #
      # if it is a method call compared with current_user or current_user.id,
      # and there is a redirect_to method call in the block body,
      # then it should be replaced by using scope access.
      add_callback :start_if, :start_unless, :start_elsif, :start_ifop, :start_if_mod, :start_unless_mod do |node|
        add_error 'use scope access' if current_user_redirect?(node)
      end

      private

        # check a if node to see
        #
        # if the conditional statement is compared with current_user or current_user.id,
        # and there is a redirect_to method call in the block body,
        # then it should be replaced by using scope access.
      def current_user_redirect?(node)
        all_conditions = if node.conditional_statement == node.conditional_statement.all_conditions
                           [node.conditional_statement]
                         else
                           node.conditional_statement.all_conditions
        end
        results = all_conditions.map do |condition_node|
          ['==', '!='].include?(condition_node.message.to_s) &&
            (current_user?(condition_node.argument) || current_user?(condition_node.receiver))
        end
        results.any? { |result| result == true } && node.body.grep_node(message: 'redirect_to')
      end

        # check a call node to see if it uses current_user, or current_user.id.
      def current_user?(node)
        node.to_s == 'current_user' || (node.receiver.to_s == 'current_user' && node.message.to_s == 'id')
      end
    end
  end
end
