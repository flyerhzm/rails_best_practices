# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check db/schema.rb file to make sure every reference key has a database index.
    #
    # Implementation: read all add_index method calls to get the indexed columns in table, then read integer method call in create_table block to get the reference columns in tables (or polymorphic index like [commentable_id, commentable_type]), compare with indexed columns, if not in the indexed columns, then it violates always_add_db_index_check.
    class AlwaysAddDbIndexCheck < Check

      def interesting_nodes
        [:block, :call, :iter]
      end

      def interesting_files
        /db\/schema.rb/
      end

      def initialize
        super
        @index_columns = {}
        @foreign_keys = {}
        @table_nodes = {}
      end

      def evaluate_start(node)
        if :block == node.node_type
          find_index_columns(node)
        elsif :call == node.node_type
          case node.message
          when :create_table
            @table_name = node.arguments[1].to_s
            @table_nodes[@table_name] = node
          when :integer, :string
            column_name = node.arguments[1].to_s
            add_foreign_key_column(@table_name, column_name)
          end
        end
      end

      def evaluate_end(node)
        if :iter == node.node_type && :call == node.subject.node_type && s(:colon2, s(:const, :ActiveRecord), :Schema) == node.subject.subject
          @foreign_keys.each do |table, foreign_key|
            table_node = @table_nodes[table]
            foreign_key.each do |column|
              unless @index_columns[table] && @index_columns[table].include?(column)
                add_error "always add db index (#{table} => [#{Array(column).join(', ')}])", table_node.file, table_node.line
              end
            end
          end
        end
      end

      private
        def find_index_columns(node)
          node.grep_nodes({:node_type => :call, :message => :add_index}).each do |index_node|
            table_name = index_node.arguments[1].to_s
            index_column = eval(index_node.arguments[2].to_s)
            add_index_column(table_name, index_column)
          end
        end

        def add_index_column(table_name, index_column)
          @index_columns[table_name] ||= []
          @index_columns[table_name] << (index_column.size == 1 ? index_column[0] : index_column)
        end

        def add_foreign_key_column(table_name, foreign_key_column)
          if foreign_key_column =~ /_id$/
            @foreign_keys[table_name] ||= []
            @foreign_keys[table_name] << foreign_key_column
          elsif foreign_key_column =~ /(.*?)_type$/
            @foreign_keys[table_name].delete("#{$1}_id")
            @foreign_keys[table_name] << ["#{$1}_id", foreign_key_column]
          end
        end
    end
  end
end
