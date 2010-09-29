# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check config/deploy.rb file to make sure using the bundler's capistrano recipe.
    #
    # Implementation: check the method call,
    # if there is a method call "namespace" with argument ":bundler", then it should use bundler's capistrano recipe.
    class DryBundlerInCapistranoCheck < Check

      def interesting_nodes
        [:call]
      end

      def interesting_files
        /config\/deploy.rb/
      end

      def evaluate_start(node)
        if :namespace == node.message and "bundler" == node.arguments.to_ruby_string
          add_error "dry bundler in capistrano"
        end
      end
    end
  end
end
