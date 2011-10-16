# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    class RemoveUnusedMethodsInModelsReview < Review
      include Klassable
      include Completeable

      EXCEPT_METHODS = %w(initialize validate to_xml to_json)

      def interesting_nodes
        [:module, :class, :call, :fcall, :command, :method_add_arg, :var_ref]
      end

      def initialize(options={})
        super()
        @model_methods = Prepares.model_methods
        @except_methods = EXCEPT_METHODS + options['except_methods']
      end

      def start_call(node)
        mark_used(node.message)
      end

      def start_fcall(node)
        mark_used(node.message)
      end

      def start_var_ref(node)
        mark_used(node)
      end

      def start_command(node)
        unless %w(named_scope scope).include? node.message.to_s
          mark_used(node.message)
          node.arguments.all.each { |argument| mark_used(argument) }
        end
      end

      def start_method_add_arg(node)
        if "try" == node.message.to_s
          method_name = node.arguments.all[0].to_s
          call_method(method_name)
        end
      end

      def on_complete
        @model_methods.get_all_unused_methods.each do |method|
          if !@except_methods.include?(method.method_name) && method.method_name !~ /=$/
            add_error "remove unused methods (#{method.class_name}##{method.method_name})", method.file, method.line
          end
        end
      end

      private
        def mark_used(method_node)
          if :bare_assoc_hash == method_node.sexp_type
            method_node.hash_values.each { |value_node| mark_used(value_node) }
          elsif :array == method_node.sexp_type
            method_node.array_values.each { |value_node| mark_used(value_node) }
          else
            method_name = method_node.to_s
          end
          call_method(method_name)
        end

        def call_method(method_name)
          if @model_methods.has_method?(current_class_name, method_name)
            @model_methods.get_method(current_class_name, method_name).mark_used
          end
          @model_methods.mark_extend_class_method_used(current_class_name, method_name)
          @model_methods.possible_public_used(method_name)
        end
    end
  end
end
