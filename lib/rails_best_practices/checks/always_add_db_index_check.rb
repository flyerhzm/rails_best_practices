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
        [:defs]
      end

      def interesting_files
        /db\/migrate\/.*rb/
      end

      def initialize
        super
        @files = []
        @references = {}
        @indexes = {}
        @parse = false
      end

      def evaluate_start(node)
        if @files.include? node.file
          @parse = true if :up == node.message
        else
          @files << node.file
        end

        if @parse and :up == node.message
          @references.each do |table_name, column_names|
            differences = column_names - (@indexes[table_name] || [])
            @references[table_name] = column_names - differences
            hint = differences.collect {|column_name| "#{table_name} => #{column_name}"}.join(', ')
            add_error "always add db index (#{hint})" unless differences.empty?
          end
        else
          remember_references(node.body)
          remember_indexes(node.body)
        end
      end

      private

      def remember_references(node)
        create_table_node = node.grep_nodes({:node_type => :call, :message => :create_table}).first
        if create_table_node
          table_name = eval(create_table_node.arguments[1].to_ruby).to_s
          node.grep_nodes({:node_type => :call, :message => :integer}).each do |integer_node|
            column_name = eval(integer_node.arguments[1].to_ruby).to_s
            if column_name =~ /_id$/
              @references[table_name] ||= []
              @references[table_name] << column_name
            end
          end
          node.grep_nodes({:node_type => :call, :message => :references}).each do |references_node|
            column_name = eval(references_node.arguments[1].to_ruby).to_s + "_id"
            @references[table_name] ||= []
            @references[table_name] << column_name
          end
          node.grep_nodes({:node_type => :call, :message => :column}).each do |column_node|
            if 'integer' == eval(column_node.arguments[2].to_ruby).to_s
              column_name = eval(column_node.arguments[1].to_ruby).to_s
              if column_name =~ /_id$/
                @references[table_name] ||= []
                @references[table_name] << column_name
              end
            end
          end
        end
      end

      def remember_indexes(node)
        add_index_nodes = node.grep_nodes({:node_type => :call, :message => :add_index})
        add_index_nodes.each do |add_index_node|
          table_name = eval(add_index_node.arguments[1].to_ruby).to_s
          column_name = eval(add_index_node.arguments[2].to_ruby).to_s
          @indexes[table_name] ||= []
          @indexes[table_name] << column_name
        end
      end
    end
  end
end
