# encoding: utf-8
module RailsBestPractices
  module Core
    class ModelAttributes
      def initialize
        @attributes = {}
      end

      def add_attribute(model_name, attribute_name, attribute_type)
        @attributes[model_name] ||= {}
        @attributes[model_name][attribute_name] = attribute_type
      end

      def get_attribute_type(model_name, attribute_name)
        @attributes[model_name][attribute_name]
      end

      def is_attribute?(model_name, attribute_name)
        !!@attributes[model_name][attribute_name]
      end
    end
  end
end
