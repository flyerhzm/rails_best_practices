# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Find out unused methods in models.
    #
    # Implemenation:
    #
    # Review process:
    #   remember all method calls,
    #   at end, check if all defined methods are called,
    #   if not, non called methods are unused.
    class RemoveUnusedMethodsInModelsReview < Review
      include Klassable
      include Completeable

      EXCEPT_METHODS = %w(initialize validate to_xml to_json assign_attributes)

      def interesting_nodes
        [:module, :class, :call, :fcall, :command, :command_call, :method_add_arg, :var_ref, :alias, :bare_assoc_hash]
      end

      def initialize(options={})
        super()
        @model_methods = Prepares.model_methods
        @except_methods = EXCEPT_METHODS + options['except_methods']
      end

      # remember the message of call node.
      def start_call(node)
        mark_used(node.message)
      end

      # remember the message of fcall node.
      def start_fcall(node)
        mark_used(node.message)
      end

      # remember name of var_ref node.
      def start_var_ref(node)
        mark_used(node)
      end

      # remember the message of command call node.
      def start_command_call(node)
        mark_used(node.message)
      end

      # remember the message of command node.
      # remember the argument of alias_method and alias_method_chain as well.
      def start_command(node)
        case node.message.to_s
        when "named_scope", "scope"
          # nothing
        when "alias_method"
          mark_used(node.arguments.all[1])
        when "alias_method_chain"
          method, feature = *node.arguments.all.map(&:to_s)
          call_method("#{method}_with_#{feature}")
        else
          mark_used(node.message)
          node.arguments.all.each { |argument| mark_used(argument) }
        end
      end

      # remember the old method of alias node.
      def start_alias(node)
        mark_used(node.old_method)
      end

      # remember hash values for hash key "methods".
      #
      #     def to_xml(options = {})
      #       super options.merge(:exclude => :visible, :methods => [:is_discussion_conversation])
      #     end
      def start_bare_assoc_hash(node)
        if node.hash_keys.include? "methods"
          mark_used(node.hash_value("methods"))
        end
      end

      # remember the first argument for try and send method.
      def start_method_add_arg(node)
        case node.message.to_s
        when "try"
          method_name = node.arguments.all[0].to_s
          call_method(method_name)
        when "send"
          if [:symbol_literal, :string_literal].include?(node.arguments.all[0].sexp_type)
            method_name = node.arguments.all[0].to_s
            call_method(method_name)
          end
        else
          # nothing
        end
      end

      # get all unused methods at the end of review process.
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
          @model_methods.mark_parent_class_method_used(current_class_name, method_name)
          @model_methods.mark_subclasses_method_used(current_class_name, method_name)
          @model_methods.possible_public_used(method_name)
        end
    end
  end
end
