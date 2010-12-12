# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check config/routes.rb file to make sure not to use too deep nesting routes.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/11-needless-deep-nesting.
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   chech all iter nodes in route file.
    #
    #   it is a recursively check in :iter node,
    #
    #   if it is a :iter node,
    #   increment @counter at the beginning of resources,
    #   decrement @counter at the end of resrouces,
    #   recursively check nodes in iter's block body.
    #
    #   if it is a :block node,
    #   then recursively check all child nodes in block node.
    #
    #   if it is a :call node,
    #   and the message of the node is :resources or :resource,
    #   and the @counter is greater than @nested_count defined,
    #   then it is a needless deep nesting.
    class NeedlessDeepNestingCheck < Check

      def interesting_review_nodes
        [:call, :iter]
      end

      def interesting_review_files
        ROUTE_FILE
      end

      def initialize(options = {})
        super()
        @counter = 0
        @nested_count = options['nested_count'] || 2
      end

      # check all iter node in review process.
      #
      # It is a recursively check,
      #
      # if it is a :iter node, like
      #
      #     resources posts do
      #       ...
      #     end
      # increment @counter at the beginning of resources,
      # decrement @counter at the end of iter resources,
      # recursively check the block body.
      #
      # if it is a :block node, like
      #
      #     resources :posts do
      #       resources :comments
      #       resources :votes
      #     end
      #
      # just recursively check each child node in block node.
      #
      # if it is a :call node with message :resources or :resource, like
      #
      #     resources :comments
      #
      # test if the @counter is greater than or equal to @nested_count,
      # if so, it is a needless deep nesting.
      def review_start_iter(node)
        recursively_check(node)
      end

      private
        # check nested route.
        #
        # if the node type is :iter,
        # and the subject of the node is with message :resources or :resource, like
        #
        #     s(:iter,
        #       s(:call, nil, :resources,
        #         s(:arglist, s(:lit, :posts))
        #       ),
        #       nil,
        #       s(:call, nil, :resources,
        #         s(:arglist, s(:lit, :comments))
        #       )
        #     )
        #
        # then increment the @counter, recursively check the block body, and decrement the @counter.
        #
        # if the node type is :block, it is the block body of :iter node, like
        #
        #     s(:block,
        #       s(:call, nil, :resources, s(:arglist, s(:lit, :comments))),
        #       s(:call, nil, :resources, s(:arglist, s(:lit, :votes)))
        #     )
        #
        # then check the each child node in the block.
        #
        # if the node type is :call,
        # and the message of node is :resources or :resource, like
        #
        #     s(:call, nil, :resources, s(:arglist, s(:lit, :comments)))
        #
        # then check if @counter is greater than or equal to @nested_count,
        # if so, it is the needless deep nesting.
        def recursively_check(node)
          if :iter == node.node_type && :resources == node.subject.message
            @counter += 1
            recursively_check(node.block_body)
            @counter -= 1
          elsif :block == node.node_type
            node.children.each do |child_node|
              recursively_check(child_node)
            end
          elsif :call == node.node_type && [:resources, :resource].include?(node.message)
            add_error "needless deep nesting (nested_count > #{@nested_count})", node.file, node.line if @counter >= @nested_count
          end
        end
    end
  end
end
