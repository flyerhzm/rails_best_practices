# encoding: utf-8
# frozen_string_literal: true

module RailsBestPractices
  module Core
    # Model attributes container.
    class ModelAttributes
      def initialize
        @attributes = {}
      end

      # Add a model attribute.
      #
      # @param [String] model name
      # @param [String] attribute name
      # @param [String] attribute type
      def add_attribute(model_name, attribute_name, attribute_type)
        @attributes[model_name] ||= {}
        @attributes[model_name][attribute_name] = attribute_type
      end

      # Get attribute type.
      #
      # @param [String] model name
      # @param [String] attribute name
      # @return [String] attribute type
      def get_attribute_type(model_name, attribute_name)
        @attributes[model_name] ||= {}
        @attributes[model_name][attribute_name]
      end

      # If it is a model's attribute.
      #
      # @param [String] model name
      # @param [String] attribute name
      # @return [Boolean] true if it is the model's attribute
      def is_attribute?(model_name, attribute_name)
        @attributes[model_name] ||= {}
        !!@attributes[model_name][attribute_name]
      end
    end
  end
end
