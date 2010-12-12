# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a controller file to make sure there are no complex finder.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/1-move-finder-to-named_scope.
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   check all method calls in controller files.
    #   if there is any call node with message find, all, first or last,
    #   and it has a hash argument,
    #   then it is a complex finder, and should be moved to model's named scope.
    class MoveFinderToNamedScopeCheck < Check

      FINDER = [:find, :all, :first, :last]

      def interesting_review_nodes
        [:call]
      end

      def interesting_review_files
        CONTROLLER_FILES
      end

      # check call node if its message is one of :find, :all, :first or :last,
      # and it has a hash argument,
      # then the call node is the finder that should be moved to model's named_scope.
      def review_start_call(node)
        add_error "move finder to named_scope" if finder?(node)
      end

      private
        # check if the call node is a finder.
        #
        # if the subject of call node is a constant,
        # and the message of call node is one of find, all, first or last,
        # and any of its arguments is a hash,
        # then it is a finder. e.g.
        #
        #     s(:call, s(:const, :Post), :find,
        #       s(:arglist, s(:lit, :all),
        #         s(:hash,
        #           s(:lit, :conditions),
        #           s(:hash, s(:lit, :state), s(:str, "public")),
        #           s(:lit, :limit),
        #           s(:lit, 10),
        #           s(:lit, :order),
        #           s(:str, "created_at desc")
        #         )
        #       )
        #     )
        def finder?(call_node)
          :const == call_node.subject.node_type && FINDER.include?(call_node.message) && call_node.arguments.children.any? { |node| :hash == node.node_type }
        end
    end
  end
end
