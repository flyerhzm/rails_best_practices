# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a migration file to make sure to use say_with_time for customized data changes to produce a more readable output.
    #
    # Implementation: check if there are any first level messages called in self.up and self.down except say_with_time and default migration messages (such as :add_column and :create_table)
    class UseSayWithTimeInMigrationsCheck < Check

      DEFAULT_MIGRATION_MESSAGES = [:add_column, :add_index, :add_timestamps, :change_column, :change_column_default, :change_table, :create_table, :drop_table, :remove_column, :remove_index, :remove_timestamps, :rename_column, :rename_index, :rename_table]

      def interesting_nodes
        [:defs]
      end

      def interesting_files
        MIGRATION_FILES
      end

      def evaluate_start(node)
        block_body = node.grep_nodes(:node_type => :block).first.body
        block_body.each do |iter|
          if :iter == iter.node_type and :call == iter[1].node_type and !(DEFAULT_MIGRATION_MESSAGES << :say_with_time).include? iter[1].message
            add_error("use say with time in migrations", iter[1].file, iter[1].line)
          end
        end
      end
    end
  end
end
