# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remember all gems in Gemfile
    class GemfilePrepare < Core::Check
      interesting_nodes :command
      interesting_files GEMFILE

      def initialize
        @gems = Prepares.gems
      end

      # Check all command nodes to get gem names.
      add_callback :start_command do |node|
        if "gem" == node.message.to_s
          @gems << node.arguments.to_s
        end
      end
    end
  end
end
