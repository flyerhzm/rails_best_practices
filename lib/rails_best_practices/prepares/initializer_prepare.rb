# encoding: utf-8

module RailsBestPractices
  module Prepares
    # Check all initializers
    class InitializerPrepare < Core::Check
      interesting_nodes :method_add_arg, :class
      interesting_files INITIALIZER_FILES

      def initialize
        @configs = Prepares.configs
      end

      # check if AR include ActiveModel::ForbiddenAttributesProtection
      add_callback :start_method_add_arg do |node|
        if include_forbidden_attributes_protection?(node)
          @configs["railsbp.include_forbidden_attributes_protection"] = "true"
        end
      end

      # check if the node is
      #     ActiveRecord::Base.send(:include, ActiveModel::ForbiddenAttributesProtection)
      def include_forbidden_attributes_protection?(node)
        "ActiveRecord::Base" == node.receiver.to_s &&
          "send" == node.message.to_s &&
          ["include", "ActiveModel::ForbiddenAttributesProtection"] == node.arguments.all.map(&:to_s)
      end
    end
  end
end
