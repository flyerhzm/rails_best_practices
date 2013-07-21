# encoding: utf-8
module RailsBestPractices
  module Prepares
    # Remember the model attributes.
    class SchemaPrepare < Core::Check
      interesting_nodes :command, :command_call
      interesting_files SCHEMA_FILE

      # all attribute types
      ATTRIBUTE_TYPES = %w(integer float boolean string text date time datetime binary)

      def initialize
        @model_attributes = Prepares.model_attributes
      end

      add_callback :start_command do |node|
        if "create_table" == node.message.to_s
          @last_klazz = node.arguments.all.first.to_s.classify
        end
      end

      # check command_call node to remember the model attributes.
      add_callback :start_command_call do |node|
        if ATTRIBUTE_TYPES.include? node.message.to_s
          attribute_name = node.arguments.all.first.to_s
          @model_attributes.add_attribute(@last_klazz, attribute_name, node.message.to_s)
        end
      end
    end
  end
end
