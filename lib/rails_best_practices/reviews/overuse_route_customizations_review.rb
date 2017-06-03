# encoding: utf-8
module RailsBestPractices
  module Reviews
    # Review config/routes.rb file to make sure there are no overuse route customizations.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/07/22/overuse-route-customizations/
    #
    # Implementation:
    #
    # Review process:
    #
    #   check all method_add_block nodes in route file.
    #   if the receiver of method_add_block node is with message resources,
    #   and in the block body of method_add_block node, there are more than @customize_count command nodes,
    #   whose message is get, post, update or delete,
    #   then these custom routes are overuse.
    class OveruseRouteCustomizationsReview < Review
      interesting_nodes :command_call, :method_add_block
      interesting_files ROUTE_FILES
      url "https://rails-bestpractices.com/posts/2010/07/22/overuse-route-customizations/"

      VERBS = %w(get post update delete)

      def initialize(options = {})
        super(options)
        @customize_count = options['customize_count'] || 3
      end

      # check method_add_block node to see if the count of member and collection custom routes is more than @customize_count defined.
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

        # check method_add_block node to calculate the count of member and collection custom routes.
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
