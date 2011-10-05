# encoding: utf-8
module RailsBestPractices
  module Core
    class Methods
      def initialize
        @methods = {}
      end

      def add_method(model_name, method_name)
        @methods[model_name] ||= []
        @methods[model_name] << method_name
      end

      def get_methods(model_name)
        @methods[model_name] ||= []
        @methods[model_name].to_a
      end

      def has_method?(model_name, method_name)
        @methods[model_name] ||= []
        @methods[model_name].include? method_name
      end
    end
  end
end

