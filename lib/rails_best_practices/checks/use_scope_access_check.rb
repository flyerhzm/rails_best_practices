# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a controller to make sure to use scope access instead of manually checking current_user and redirect.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/3-use-scope-access.
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   check all if nodes to see
    #
    #   if they are compared with current_user or current_user.id,
    #   and there is redirect_to method call in if block body,
    #   then it should be replaced by using scope access.
    class UseScopeAccessCheck < Check

      def interesting_review_nodes
        [:if]
      end

      def interesting_review_files
        CONTROLLER_FILES
      end

      # check if node in review process.
      #
      # if it is a method call compared with current_user or current_user.id,
      # and there is a redirect_to method call in the block body, like
      #
      #     unless @post.user == current_user
      #       falsh[:error] = "Access Denied"
      #       redirect_to posts_url
      #     end
      #
      # then it should be replaced by using scope access.
      def review_start_if(node)
        add_error "use scope access" if current_user_redirect?(node)
      end

      private
        # check a if node to see
        #
        # if the conditional statement is compared with current_user or current_user.id,
        # and there is a redirect_to method call in the block body, like
        #
        #     s(:if,
        #       s(:call,
        #         s(:call, s(:ivar, :@post), :user, s(:arglist)),
        #         :==,
        #         s(:arglist, s(:call, nil, :current_user, s(:arglist)))
        #       ),
        #       nil,
        #       s(:block,
        #         s(:attrasgn,
        #           s(:call, nil, :flash, s(:arglist)),
        #           :[]=,
        #           s(:arglist, s(:lit, :warning), s(:str, "Access Denied"))
        #         ),
        #         s(:call, nil, :redirect_to,
        #           s(:arglist, s(:call, nil, :posts_url, s(:arglist)))
        #         )
        #       )
        #     )
        #
        # then it should be replaced by using scope access.
        def current_user_redirect?(node)
          condition_node = node.conditional_statement

          condition_node.message == :== &&
          (current_user?(condition_node.arguments[1]) || current_user?(condition_node.subject)) &&
          (node.false_node.grep_node(:message => :redirect_to) || node.true_node.grep_node(:message => :redirect_to))
        end

        # check a call node to see if it uses current_user, or current_user.id.
        #
        # the expected call node may be
        #
        #     s(:call, nil, :current_user, s(:arglist))
        #
        # or
        #
        #     s(:call, s(:call, nil, :current_user, s(:arglist)), :id, s(:arglist))
        def current_user?(call_node)
          call_node.message == :current_user || (call_node.subject.message == :current_user && call_node.message == :id)
        end
    end
  end
end
