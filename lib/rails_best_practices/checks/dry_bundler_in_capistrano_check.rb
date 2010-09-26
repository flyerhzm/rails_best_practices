# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    class DryBundlerInCapistranoCheck < Check

      def interesting_nodes
        [:call]
      end

      def interesting_file
        'config/deploy.rb'
      end

      def evaluate_start(node)
        if :namespace == node.message and "bundler" == node.arguments.to_ruby_string
          add_error "dry bundler in capistrano"
        end
      end
    end
  end
end
