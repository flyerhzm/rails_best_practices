require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a migration file to make sure not to insert data in migration, move them to seed file.
    #
    # Implementation: check if there are :create, :create!, and :new with :save or :save! exist, the migration file needs isolate seed data.
    class IsolateSeedDataCheck < Check

      def interesting_nodes
        [:defs, :call, :lasgn]
      end

      def interesting_files
        MIGRATION_FILES
      end

      def initialize
        super
        @new_variables = []
        @files = []
        @parse = false
      end

      def evaluate_start(node)
        # check duplicate migration because of always_add_db_index_check.
        if :defs == node.node_type
          if @files.include? node.file
            @parse = true if :up == node.message
          else
            @files << node.file
          end
        end
        
        if @parse
          if [:create, :create!].include? node.message
            add_error("isolate seed data")
          elsif :lasgn == node.node_type
            remember_new_variable(node)
          elsif [:save, :save!].include? node.message
            add_error("isolate seed data") if new_record?(node)
          end
        end
      end

      private

      def remember_new_variable(node)
        unless node.grep_nodes({:node_type => :call, :message => :new}).empty?
          @new_variables << node.subject.to_s
        end
      end

      def new_record?(node)
        @new_variables.include? node.subject.to_ruby
      end
    end
  end
end
