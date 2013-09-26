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
      def initialize(class_name, extend_class_name, modules)
        @class_name = class_name
        @extend_class_name = extend_class_name
        @modules = modules.dup
      end

      def class_name
        if @modules.empty?
          @class_name
        else
          @modules.map { |modu| "#{modu}::" }.join("") + @class_name
        end
      end

      def extend_class_name
        if @modules.empty?
          @extend_class_name
        else
          @modules.map { |modu| "#{modu}::" }.join("") + @extend_class_name
        end
      end

      def to_s
        class_name
      end
    end
  end
end
