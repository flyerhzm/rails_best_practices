# encoding: utf-8
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
      attr_reader :class_name, :extend_class_name

      def initialize(class_name, extend_class_name, modules)
        @class_name = class_name
        @extend_class_name = extend_class_name
        @modules = modules.dup
      end

      def to_s
        if @modules.empty?
          @class_name
        else
          @modules.map { |modu| "#{modu}::" }.join("") + @class_name
        end
      end
    end
  end
end
