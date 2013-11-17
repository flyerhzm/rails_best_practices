# encoding: utf-8
module RailsBestPractices
  module Reviews
    # Review config/routes.rb file to make sure there are no overuse route customizations.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/10-overuse-route-customizations.
    #
    # Implementation:
    #
    # Review process:
    #   the check methods are different for rails2 and rails3 syntax.
    #
    #   for rails2
    #
    #   check all command_call nodes in route file.
    #   if the message of command_call node is resources,
    #   and the second argument of command_call node is a hash,
    #   and the count of the pair (key/value) in hash is greater than @customize_count,
    #   then these custom routes are overuse.
    #
    #   for rails3
    #
    #   check all method_add_block nodes in route file.
    #   if the receiver of method_add_block node is with message resources,
    #   and in the block body of method_add_block node, there are more than @customize_count command nodes,
    #   whose message is get, post, update or delete,
    #   then these custom routes are overuse.
    class OveruseRouteCustomizationsReview < Review
      interesting_nodes :command_call, :method_add_block
      interesting_files ROUTE_FILES
      url "http://rails-bestpractices.com/posts/10-overuse-route-customizations"

      VERBS = %w(get post update delete)

      def initialize(options = {})
        super(options)
        @customize_count = options['customize_count'] || 3
      end

      # check command_call node to see if the count of member and collection custom routes is more than @customize_count defined.
      # this is for rails2 syntax.
      #
      # if the message of call node is "resources",
      # and the second argument of call node is a hash,
      # and the count of the pair (key/value) in hash is greater than @customize_count,
      # then they are overuse route customizations.
      add_callback :start_command_call do |node|
        if member_and_collection_count_for_rails2(node) > @customize_count
          add_error "overuse route customizations (customize_count > #{@customize_count})", node.file, node.receiver.line_number
        end
      end

      # check method_add_block node to see if the count of member and collection custom routes is more than @customize_count defined.
      # this is for rails3 syntax.
      #
      # if the receiver of method_add_block node is with message "resources",
      # and in the block body of method_add_block node, there are more than @customize_count call nodes,
      # whose message is :get, :post, :update or :delete,
      # then they are overuse route customizations.
      add_callback :start_method_add_block do |node|
        if member_and_collection_count_for_rails3(node) > @customize_count
          add_error "overuse route customizations (customize_count > #{@customize_count})", node.file, node.line_number
        end
      end

      private
        # check command_call node to calculate the count of member and collection custom routes.
        # this is for rails2 syntax.
        #
        # if the message of command_call node is "resources",
        # and the second argument is a hash,
        # then calculate the pair (key/value) count,
        # it is just the count of member and collection custom routes.
        def member_and_collection_count_for_rails2(node)
          if "resources" == node.message.to_s
            hash_node = node.arguments.all.last
            if hash_node && :bare_assoc_hash == hash_node.sexp_type
              member_node = hash_node.hash_value("member")
              collection_node = hash_node.hash_value("collection")
              return (member_node.hash_size || member_node.array_size) + (collection_node.hash_size || collection_node.array_size)
            end
          end
          0
        end

        # check method_add_block node to calculate the count of member and collection custom routes.
        # this is for rails3 syntax.
        #
        # if its receiver is with message "resources",
        # then calculate the count of call nodes, whose message is get, post, update or delete,
        # it is just the count of member and collection custom routes.
        def member_and_collection_count_for_rails3(node)
          "resources" == node[1].message.to_s ? node.grep_nodes_count(sexp_type: :command, message: VERBS) : 0
        end
    end
  end
end
