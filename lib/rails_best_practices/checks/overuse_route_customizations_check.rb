# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check config/routes.rb to make sure there are no much route customizations.
    #
    # Implementation: check member and collection route count, if more than customize_count, then it is overuse route customizations.
    class OveruseRouteCustomizationsCheck < Check
      
      def interesting_nodes
        [:call, :iter]
      end
      
      def interesting_files
        /config\/routes.rb/
      end

      def initialize(options = {})
        super()
        @customize_count = options['customize_count'] || 3
      end
      
      def evaluate_start(node)
        add_error "overuse route customizations (customize_count > #{@customize_count})", node.file, node.subject.line if member_and_collection_count(node) > @customize_count
      end

      private
        def member_and_collection_count(node)
          if :resources == node.message
            member_and_collection_count_for_rails2(node)
          elsif :iter == node.node_type and :resources == node.subject.message
            member_and_collection_count_for_rails3(node)
          end
        end

        # this is the checker for rails3 style routes
        def member_and_collection_count_for_rails3(node)
          get_nodes = node.grep_nodes(:node_type => :call, :message => :get)
          post_nodes = node.grep_nodes(:node_type => :call, :message => :post)
          get_nodes.size + post_nodes.size
        end
        
        # this is the checker for rails2 style routes
        def member_and_collection_count_for_rails2(node)
          hash_nodes = node.grep_nodes(:node_type => :hash)
          return 0 if hash_nodes.empty?
          hash_key_node = hash_nodes.first[1]
          if :lit == hash_key_node.node_type and [:member, :collection].include? hash_key_node[1]
            customize_hash = eval(hash_nodes.first.to_s)
            (customize_hash[:member].size || 0) + (customize_hash[:collection].size || 0)
          end
        end
    end
  end
end
