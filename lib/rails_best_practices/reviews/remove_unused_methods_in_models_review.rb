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
      include Callable
      include Exceptable

      interesting_nodes :command
      interesting_files ALL_FILES

      def initialize(options={})
        super
        @model_methods = Prepares.model_methods
      end

      # skip scope and validate nodes for start_command callbacks.
      def skip_command_callback_nodes
        %w(named_scope scope validate validate_on_create validate_on_update)
      end

      # mark validate methods as used.
      def start_command(node)
        case node.message.to_s
        when "validate", "validate_on_create", "validate_on_update"
          node.arguments.all.each { |argument| mark_used(argument) }
        else
          # nothing
        end
      end

      # get all unused methods at the end of review process.
      def on_complete
        @model_methods.get_all_unused_methods.each do |method|
          if !excepted?(method) && method.method_name !~ /=$/
            add_error "remove unused methods (#{method.class_name}##{method.method_name})", method.file, method.line
          end
        end
      end

      protected
        def methods
          @model_methods
        end

        def internal_except_methods
          %w(initialize validate to_xml to_json assign_attributes after_find after_initialize).map { |method_name| "*\##{method_name}" }
        end
    end
  end
end
