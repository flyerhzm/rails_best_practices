# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review config/routes.rb file to make sure not to use too deep nesting routes.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/11-needless-deep-nesting.
    #
    # Implementation:
    #
    # Review process:
    #   chech all method_add_block nodes in route file.
    #
    #   it is a recursively check in method_add_block node,
    #
    #   if it is a method_add_block node,
    #   increment @counter at the beginning of resources,
    #   decrement @counter at the end of resrouces,
    #   recursively check nodes in block body.
    #
    #   if the child node is a command_call or command node,
    #   and the message of the node is "resources" or "resource",
    #   and the @counter is greater than @nested_count defined,
    #   then it is a needless deep nesting.
    class NeedlessDeepNestingReview < Review
      interesting_nodes :method_add_block
      interesting_files ROUTE_FILES

      def url
        "http://rails-bestpractices.com/posts/11-needless-deep-nesting"
      end

      def initialize(options = {})
        super()
        @counter = 0
        @nested_count = options['nested_count'] || 2
        @shallow_nodes = []
      end

      # check all method_add_block node.
      #
      # It is a recursively check, if it is a method_add_block node,
      # increment @counter at the beginning of resources,
      # decrement @counter at the end of method_add_block resources,
      # recursively check the block body.
      #
      # if the child node is a command_call or command node with message "resources" or "resource",
      # test if the @counter is greater than or equal to @nested_count,
      # if so, it is a needless deep nesting.
      def start_method_add_block(node)
        @file = node.file
        recursively_check(node)
      end

      private
        # check nested route.
        #
        # if the subject of the method_add_block is with message "resources" or "resource",
        # then increment the @counter, recursively check the block body, and decrement the @counter.
        #
        # if the node type is command_call or command,
        # and its message is resources or resource,
        # then check if @counter is greater than or equal to @nested_count,
        # if so, it is the needless deep nesting.
        def recursively_check(node)
          shallow = @shallow_nodes.include? node
          if [:command_call, :command].include?(node[1].sexp_type) && ["resources", "resource"].include?(node[1].message.to_s)
            hash_node = node[1].arguments.grep_node(sexp_type: :bare_assoc_hash)
            shallow = (hash_node && "true" == hash_node.hash_value("shallow").to_s) unless shallow
            @counter += 1
            node.block.statements.each do |stmt_node|
              @shallow_nodes << stmt_node if shallow
              recursively_check(stmt_node)
            end
            @counter -= 1
          elsif [:command_call, :command].include?(node.sexp_type) && ["resources", "resource"].include?(node.message.to_s)
            add_error "needless deep nesting (nested_count > #{@nested_count})", @file, node.line if @counter >= @nested_count && !@shallow_nodes.include?(node)
          end
        end
    end
  end
end
