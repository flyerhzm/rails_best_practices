require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a migration file to make sure not to insert data in migration, move them to seed file.
    #
    # Implementation: check if there are :create, :create!, and :new with :save or :save! exist, the migration file needs isolate seed data.
    class IsolateSeedDataCheck < Check

      def interesting_nodes
        [:call, :lasgn]
      end

      def interesting_files
        MIGRATION_FILES
      end

      def initialize
        super
        @new_variables = []
      end

      def evaluate_start(node)
        if [:create, :create!].include? node.message
          add_error("isolate seed data")
        elsif :lasgn == node.node_type
          remember_new_variable(node)
        elsif [:save, :save!].include? node.message
          add_error("isolate seed data") if new_record?(node)
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
