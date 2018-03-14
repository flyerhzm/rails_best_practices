# encoding: utf-8
# frozen_string_literal: true

module RailsBestPractices
  module Prepares
    # Remember all configs
    class ConfigPrepare < Core::Check
      interesting_nodes :assign
      interesting_files CONFIG_FILES

      def initialize
        @configs = Prepares.configs
      end

      # check assignments to config
      add_callback :start_assign do |node|
        if node.left_value.grep_node(sexp_type: [:vcall, :var_ref], to_s: 'config').present?
          @configs[node.left_value.to_s] = node.right_value.to_s
        end
      end
    end
  end
end
