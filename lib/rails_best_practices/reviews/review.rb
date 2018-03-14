# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # A Review class that takes charge of reviewing one rails best practice.
    class Review < Core::Check
      # default url.
      url '#'

      # remember use count for the variable in the call or assign node.
      #
      # find the variable in the call or assign node,
      # then save it to as key in @variable_use_count hash, and add the call count (hash value).
      def remember_variable_use_count(node)
        variable_node = variable(node)
        if variable_node && 'self' != variable_node.to_s && @last_variable_node != variable_node
          @last_variable_node = variable_node
          variable_use_count[variable_node.to_s] ||= 0
          variable_use_count[variable_node.to_s] += 1
        end
      end

      # return @variable_use_count hash.
      def variable_use_count
        @variable_use_count ||= {}
      end

      # reset @variable_use_count hash.
      def reset_variable_use_count
        @variable_use_count = nil
      end

      # find variable in the call or field node.
      def variable(node)
        while %i[call field method_add_arg method_add_block].include?(node.receiver.sexp_type)
          node = node.receiver
        end
        return if %i[fcall hash].include?(node.receiver.sexp_type)
        node.receiver
      end

      # get the models from Prepares.
      #
      # @return [Array]
      def models
        @models ||= Prepares.models
      end

      # get the model associations from Prepares.
      #
      # @return [Hash]
      def model_associations
        @model_associations ||= Prepares.model_associations
      end

      # get the model attributes from Prepares.
      #
      # @return [Hash]
      def model_attributes
        @model_attributes ||= Prepares.model_attributes
      end
    end
  end
end
