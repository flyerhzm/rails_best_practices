# frozen_string_literal: true

module RailsBestPractices
  module Core
    # Klass container.
    class Klasses < Array
      # If include the class.
      #
      # @param [String] class name
      # @return [Boolean] include or not
      def include?(class_name)
        find { |klass| klass.to_s == class_name }
      end
    end

    # Class info includes class name, extend class name and module names.
    class Klass
      attr_reader :extend_class_name, :class_name

      def initialize(class_name, extend_class_name, modules)
        @modules = modules.dup
        base = @modules.map { |modu| "#{modu}::" }.join('')
        @class_name = base + class_name
        if extend_class_name
          @extend_class_name = base + extend_class_name
        end
      end

      def to_s
        class_name
      end
    end
  end
end
