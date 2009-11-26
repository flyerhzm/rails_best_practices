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
        MIGRATION_FILES
      end

      def initialize
        super
        @files = []
        @@indexes = {}
        @parse = false
      end

      # make indexes class method for get indexes out of AlwaysAddDbIndexCheck class.
      def self.indexes
        @@indexes
      end

      def evaluate_start(node)
        if @files.include? node.file
          @parse = true if :up == node.message
        else
          @files << node.file
        end

        if @parse and :up == node.message
          check_references(node.body)
        else
          remember_indexes(node.body)
        end
      end

      private

      def check_references(nodes)
        nodes[1..-1].each do |node|
          create_table_node = node.grep_nodes({:node_type => :call, :message => :create_table}).first
          if create_table_node
            table_name = create_table_node.arguments[1].to_ruby_string
            node.grep_nodes({:node_type => :call, :message => :integer}).each do |integer_node|
              column_name = integer_node.arguments[1].to_ruby_string
              if column_name =~ /_id$/ and !@@indexes[table_name].include? column_name
                add_error "always add db index (#{table_name} => #{column_name})"
              end
            end
            node.grep_nodes({:node_type => :call, :message => :references}).each do |references_node|
              column_name = references_node.arguments[1].to_ruby_string + "_id"
              if !@@indexes[table_name].include? column_name
                add_error "always add db index (#{table_name} => #{column_name})"
              end
            end
            node.grep_nodes({:node_type => :call, :message => :column}).each do |column_node|
              if 'integer' == column_node.arguments[2].to_ruby_string
                column_name = column_node.arguments[1].to_ruby_string
                if column_name =~ /_id$/ and !@@indexes[table_name].include? column_name
                  add_error "always add db index (#{table_name} => #{column_name})"
                end
              end
            end
          end
        end
      end

      # dynamically execute add_index because static parser can't handle
      #
      # [[:comments, :post_id], [:comments, :user_id]].each do |args|
      #   add_index *args
      # end
      def remember_indexes(nodes)
        nodes[1..-1].each do |node|
          begin
            eval(node.to_ruby)
          rescue Exception
          end
        end
      end
    end
  end
end

def add_index(*args)
  table_name, column_names = *args
  table_name = table_name.to_s
  RailsBestPractices::Checks::AlwaysAddDbIndexCheck.indexes[table_name] ||= []
  Array(column_names).each do |column_name|
    RailsBestPractices::Checks::AlwaysAddDbIndexCheck.indexes[table_name] << column_name.to_s
  end
end
