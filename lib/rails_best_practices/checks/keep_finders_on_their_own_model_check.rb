# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check model files to ake sure finders are on their own model.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/13-keep-finders-on-their-own-model.
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   check all call nodes in model files.
    #
    #   if the call node is a finder (find, all, first or last),
    #   and the it calls the other model,
    #   and there are arguments of finder,
    #   then it should keep finders on its own model.
    class KeepFindersOnTheirOwnModelCheck < Check

      def interesting_review_nodes
        [:call]
      end

      def interesting_review_files
        MODLE_FILES
      end

      # check all the call nodes to see if there is a finder for other model.
      #
      # if the call node is
      #
      # 1. the message of call node is one of the :find, :all, :first or :last
      # 2. the subject of call node is also a call node (it's the other model)
      # 3. the size of arguments is more than 1 (complex finder)
      #
      # then it should keep finders on its own model.
      def review_start_call(node)
        add_error "keep finders on their own model" if other_finder?(node)
      end

      private
        # check if the call node is the finder of other model.
        #
        # the message of the node should be one of :find, :all, :first or :last,
        # and the subject of the node should be with message :call (this is the other model),
        # and the arguments of the node should more than 1, like
        #
        #     s(:call,
        #       s(:call, s(:self), :comment, s(:arglist)),
        #       :find,
        #       s(:arglist, s(:lit, :all),
        #         s(:hash,
        #           s(:lit, :conditions),
        #           s(:hash, s(:lit, :is_spam), s(:false)),
        #           s(:lit, :limit),
        #           s(:lit, 10)
        #         )
        #       )
        #     )
        def other_finder?(node)
          [:find, :all, :first, :last].include?(node.message) && :call == node.subject.node_type && node.arguments.size > 1
        end
    end
  end
end
