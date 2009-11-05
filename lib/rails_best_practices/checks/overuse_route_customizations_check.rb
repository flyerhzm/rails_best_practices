require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check config/routes.rb to make sure there are no much route customizations.
    #
    # Implementation: check member and collection route count, if more than customize_count, then it is overuse route customizations.
    class OveruseRouteCustomizationsCheck < Check
      
      def interesting_nodes
        [:call]
      end
      
      def interesting_files
        /config\/routes.rb/
      end

      def initialize(options = {})
        super()
        @customize_count = options['customize_count'] || 3
      end
      
      def evaluate_start(node)
        if s(:lvar, :map) == node.subject and :resources == node.message
          add_error "overuse route customizations" if member_and_collection_count(node) > @customize_count
        end
      end

      private

      def member_and_collection_count(node)
        customize_hash = eval(node.grep_nodes(:node_type => :hash).first.to_ruby)
        (customize_hash[:member].size || 0) + (customize_hash[:collection].size || 0)
      end
    end
  end
end
