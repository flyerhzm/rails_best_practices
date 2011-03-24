# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remember the model attributes.
    class SchemaPrepare < Core::Check
      # all attribute types
      ATTRIBUTE_TYPES = [:integer, :float, :boolean, :string, :text, :date, :time, :datetime, :binary]

      def interesting_nodes
        [:call]
      end

      def interesting_files
        SCHEMA_FILE
      end

      def initialize
        @model_attributes = Core::ModelAttributes.new
      end

      # check call node to remember the model attributes.
      def start_call(call_node)
        case call_node.message
        when :create_table
          @last_klazz = call_node.arguments[1].to_s.classify
        when *ATTRIBUTE_TYPES
          attribute_name = call_node.arguments[1].to_s
          @model_attributes.add_attribute(@last_klazz, attribute_name, call_node.message)
        else
          # nothing to do
        end
      end

      # assign @model_attributes to Prepares.model_attributes.
      def end_call(call_node)
        if :create_table
          Prepares.model_attributes = @model_attributes
        end
      end
    end
  end
end
