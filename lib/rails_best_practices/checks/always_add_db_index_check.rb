require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a migration file to make sure every reference key has a database index.
    #
    # Implementation:
    # Parse migration files twice.
    # First, remember all reference keys and index keys.
    # Second, compare reference keys and index keys, and add error when reference keys are not in index keys.
    class AlwaysAddDbIndexCheck < Check

      def interesting_nodes
        [:block, :call]
      end

      def interesting_files
        /db\/schema.rb/
      end

      def initialize
        super
        @index_columns = []
      end

      def evaluate_start(node)
        if :block == node.node_type
          find_index_columns(node)
        elsif :call == node.node_type
          case node.message
          when :create_table
            @table_name = node.arguments[1].to_ruby_string
          when :integer
            column_name = node.arguments[1].to_ruby_string
            if column_name =~ /_id$/ and !indexed?(@table_name, column_name)
              add_error "always add db index (#@table_name => #{column_name})", node.file, node.line
            end
          end
        end
      end
      
      private
        def find_index_columns(node)
          node.grep_nodes({:node_type => :call, :message => :add_index}).each do |index_node|
            table_name = index_node.arguments[1].to_ruby_string
            reference_column_name = index_node.arguments[2].to_ruby_string
            @index_columns << [table_name, reference_column_name]
          end
        end
        
        def indexed?(table_name, column_name)
          !!@index_columns.find { |reference| reference[0] == table_name and reference[1] == column_name }
        end
    end
  end
end