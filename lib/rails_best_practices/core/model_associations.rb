# encoding: utf-8
module RailsBestPractices
  module Core
    class ModelAssociations
      def initialize
        @associations = {}
      end

      def add_association(model_name, association_name, association_meta, association_class=nil)
        @associations[model_name] ||= {}
        @associations[model_name][association_name] = {:meta => association_meta, :class_name => association_class || association_name.classify}
      end

      def get_association(model_name, association_name)
        associations = @associations[model_name]
        associations and associations[association_name]
      end

      def is_association?(model_name, association_name)
        associations = @associations[model_name]
        associations && associations[association_name]
      end
    end
  end
end