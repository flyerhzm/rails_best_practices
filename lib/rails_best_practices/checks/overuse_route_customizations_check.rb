# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check config/routes.rb file to make sure there are no overuse route customizations.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/10-overuse-route-customizations.
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   the check methods are different for rails2 and rails3 syntax.
    #
    #   for rails2
    #
    #   check all call nodes in route file.
    #   if the message of call node is resources,
    #   and the second argument of call node is a hash,
    #   and the count of the pair (key/value) in hash is greater than @customize_count,
    #   then these custom routes are overuse.
    #
    #   for rails3
    #
    #   check all iter nodes in route file.
    #   if the subject of iter node is with message resources,
    #   and in the block body of iter node, there are more than @customize_count call nodes,
    #   whose message is :get, :post, :update or :delete,
    #   then these custom routes are overuse.
    class OveruseRouteCustomizationsCheck < Check

      VERBS = [:get, :post, :update, :delete]

      def interesting_review_nodes
        [:call, :iter]
      end

      def interesting_review_files
        ROUTE_FILE
      end

      def initialize(options = {})
        super()
        @customize_count = options['customize_count'] || 3
      end

      # check call node to see if the count of member and collection custom routes is more than @customize_count defined in review process.
      # this is for rails2 syntax.
      #
      # if the message of call node is :resources,
      # and the second argument of call node is a hash,
      # and the count of the pair (key/value) in hash is greater than @customize_count, like
      #
      #     map.resources :posts, :member => { :create_comment => :post,
      #                                        :update_comment => :update,
      #                                        :delete_comment => :delete },
      #                           :collection => { :comments => :get }
      #
      # then they are overuse route customizations.
      def review_start_call(node)
        if member_and_collection_count_for_rails2(node) > @customize_count
          add_error "overuse route customizations (customize_count > #{@customize_count})", node.file, node.subject.line
        end
      end

      # check iter node to see if the count of member and collection custom routes is more than @customize_count defined in review process.
      # this is for rails3 syntax.
      #
      # if the subject of iter node is with message :resources,
      # and in the block body of iter node, there are more than @customize_count call nodes,
      # whose message is :get, :post, :update or :delete, like
      #
      #     resources :posts do
      #       member do
      #         post :create_comment
      #         update :update_comment
      #         delete :delete_comment
      #       end
      #
      #       collection do
      #         get :comments
      #       end
      #     end
      #
      # then they are overuse route customizations.
      def review_start_iter(node)
        if member_and_collection_count_for_rails3(node) > @customize_count
          add_error "overuse route customizations (customize_count > #{@customize_count})", node.file, node.subject.line
        end
      end

      private
        # check call node to calculate the count of member and collection custom routes.
        # this is for rails2 syntax.
        #
        # if the message of call node is :resources,
        # and the second argument is a hash,
        # then calculate the pair (key/value) count,
        # it is just the count of member and collection custom routes.
        #
        #     s(:call, s(:lvar, :map), :resources,
        #       s(:arglist,
        #         s(:lit, :posts),
        #         s(:hash,
        #           s(:lit, :member),
        #           s(:hash,
        #             s(:lit, :create_comment),
        #             s(:lit, :post),
        #             s(:lit, :update_comment),
        #             s(:lit, :update),
        #             s(:lit, :delete_comment),
        #             s(:lit, :delete)
        #           ),
        #           s(:lit, :collection),
        #           s(:hash,
        #             s(:lit, :comments),
        #             s(:lit, :get)
        #           )
        #         )
        #       )
        #     )
        def member_and_collection_count_for_rails2(node)
          if :resources == node.message
            hash_node = node.arguments[2]
            if hash_node
              (hash_node.grep_nodes_count(:node_type => :lit) - hash_node.grep_nodes_count(:node_type => :hash)) / 2
            end
          end
        end

        # check iter node to calculate the count of member and collection custom routes.
        # this is for rails3 syntax.
        #
        # if its subject is with message :resources,
        # then calculate the count of call nodes, whose message is :get, :post, :update or :delete,
        # it is just the count of member and collection custom routes.
        #
        #     s(:iter,
        #       s(:call, nil, :resources, s(:arglist, s(:lit, :posts))),
        #       nil,
        #       s(:block,
        #         s(:iter,
        #           s(:call, nil, :member, s(:arglist)),
        #           nil,
        #           s(:block,
        #             s(:call, nil, :post, s(:arglist, s(:lit, :create_comment))),
        #             s(:call, nil, :post, s(:arglist, s(:lit, :update_comment))),
        #             s(:call, nil, :post, s(:arglist, s(:lit, :delete_comment)))
        #           )
        #         ),
        #         s(:iter,
        #           s(:call, nil, :collection, s(:arglist)),
        #           nil,
        #           s(:call, nil, :get, s(:arglist, s(:lit, :comments)))
        #         )
        #       )
        #     )
        def member_and_collection_count_for_rails3(node)
          if :resources == node.subject.message
            node.grep_nodes_count(:node_type => :call, :message => VERBS)
          end
        end
    end
  end
end
