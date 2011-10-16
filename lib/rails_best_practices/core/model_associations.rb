# encoding: utf-8
module RailsBestPractices
  module Core
    # Model associations container.
    class ModelAssociations
      def initialize
        @associations = {}
      end

      # Add a model association.
      #
      # @param [String] model name
      # @param [String] association name
      # @param [String] association meta, has_many, has_one, belongs_to and has_and_belongs_to_many
      # @param [String] association class name
      def add_association(model_name, association_name, association_meta, association_class=nil)
        @associations[model_name] ||= {}
        @associations[model_name][association_name] = {"meta" => association_meta, "class_name" => association_class || association_name.classify}
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
        associations && associations[association_name]
      end
    end
  end
end
