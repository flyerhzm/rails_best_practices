# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    class ConfigPrepare < Core::Check
      interesting_nodes :assign
      interesting_files CONFIG_FILES

      def initialize
        @configs = Prepares.configs
      end

      def start_assign(node)
        if node.left_value.grep_node(:sexp_type => "vcall", :to_s => "config")
          @configs[node.left_value.to_s] = node.right_value.to_s
        end
      end
    end
  end
end
