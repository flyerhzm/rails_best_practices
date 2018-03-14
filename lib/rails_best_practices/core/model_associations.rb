# frozen_string_literal: true

module RailsBestPractices
  module Core
    # Model associations container.
    class ModelAssociations
      def initialize
        @associations = {}
      end

      #
      # @param [String] model name
      # @param [String] association name
      # @param [String] association meta, has_many, has_one, belongs_to and has_and_belongs_to_many
      # @param [String] association class name
      def add_association(model_name, association_name, association_meta, association_class = nil)
        @associations[model_name] ||= {}
        @associations[model_name][association_name] = { 'meta' => association_meta, 'class_name' => association_class || association_name.classify }
      end

      # Get a model association.
      #
      # @param [String] model name
      # @param [String] association name
      # @return [Hash] {"meta" => association_meta, "class_name" => association_class}
      def get_association(model_name, association_name)
        associations = @associations[model_name]
        associations and associations[association_name]
      end

      # If it is a model's association.
      #
      # @param [String] model name
      # @param [String] association name
      # @return [Boolean] true if it is the model's association
      def is_association?(model_name, association_name)
        associations = @associations[model_name]
        !!(associations && associations[association_name])
      end

      # delegate each to @associations.
      def each(&block)
        @associations.each { |model, model_associations| yield model, model_associations }
      end

      # Get association's class name
      #
      # @param [String] table name
      # @param [String] association_name
      # @return [String] association's class name
      def get_association_class_name(table_name, association_name)
        associations = @associations.select { |model, _model_associations| model.gsub('::', '').tableize == table_name }.values.first and
          association_meta = associations.select { |name, _meta| name == association_name }.values.first and
          association_meta['class_name']
      end
    end
  end
end
