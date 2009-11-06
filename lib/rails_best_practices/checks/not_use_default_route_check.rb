require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check config/routes to make sure not use default route that rails generated.
    #
    # Implementation: compare route sentence to see if it is equal to rails default route.
    class NotUseDefaultRouteCheck < Check
      
      def interesting_nodes
        [:call]
      end
      
      def interesting_files
        /config\/routes.rb/
      end
      
      def evaluate_start(node)
        if node == s(:call, s(:lvar, :map), :connect, s(:arglist, s(:str, ":controller/:action/:id"))) or
           node == s(:call, s(:lvar, :map), :connect, s(:arglist, s(:str, ":controller/:action/:id.:format")))
          add_error "not use default route"
        end
      end
    end
  end
end