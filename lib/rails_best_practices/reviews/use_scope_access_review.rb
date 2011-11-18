# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review a controller to make sure to use scope access instead of manually checking current_user and redirect.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/3-use-scope-access.
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
      interesting_nodes :if, :unless, :elsif
      interesting_files CONTROLLER_FILES

      def url
        "http://rails-bestpractices.com/posts/3-use-scope-access"
      end

      # check if node.
      #
      # if it is a method call compared with current_user or current_user.id,
      # and there is a redirect_to method call in the block body,
      # then it should be replaced by using scope access.
      def start_if(node)
        add_error "use scope access" if current_user_redirect?(node)
      end

      alias_method :start_unless, :start_if
      alias_method :start_elsif, :start_if

      private
        # check a if node to see
        #
        # if the conditional statement is compared with current_user or current_user.id,
        # and there is a redirect_to method call in the block body,
        # then it should be replaced by using scope access.
        def current_user_redirect?(node)
          all_conditions = node.conditional_statement == node.conditional_statement.all_conditions ? [node.conditional_statement] : node.conditional_statement.all_conditions
          results = all_conditions.map do |condition_node|
            ["==", "!="].include?(condition_node.message.to_s) && (current_user?(condition_node.argument) || current_user?(condition_node.subject))
          end
          results.any? { |result| result == true } && node.body.grep_node(:message => "redirect_to")
        end

        # check a call node to see if it uses current_user, or current_user.id.
        def current_user?(node)
          "current_user" == node.to_s || ("current_user" == node.subject.to_s && "id" == node.message.to_s)
        end
    end
  end
end
