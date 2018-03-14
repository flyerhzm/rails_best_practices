# encoding: utf-8
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
      include Classable
      include Callable
      include Exceptable

      interesting_nodes :command, :command_call, :method_add_arg
      interesting_files ALL_FILES

      def initialize(options = {})
        super
        @model_methods = Prepares.model_methods
      end

      # skip scope and validate nodes for start_command callbacks.
      def skip_command_callback_nodes
        %w(named_scope scope validate validate_on_create validate_on_update)
      end

      # mark validate methods as used.
      # mark key method and value method for collection_select and grouped_collection_select.
      add_callback :start_command do |node|
        arguments = node.arguments.all
        case node.message.to_s
        when 'validate', 'validate_on_create', 'validate_on_update'
          arguments.each { |argument| mark_used(argument) }
        when 'collection_select'
          mark_used(arguments[3])
          mark_used(arguments[4])
        when 'grouped_collection_select'
          mark_used(arguments[3])
          mark_used(arguments[4])
          mark_used(arguments[5])
          mark_used(arguments[6])
        end
      end

      # mark key method and value method for collection_select and grouped_collection_select.
      add_callback :start_command_call do |node|
        arguments = node.arguments.all
        case node.message.to_s
        when 'collection_select'
          mark_used(arguments[2])
          mark_used(arguments[3])
        when 'grouped_collection_select'
          mark_used(arguments[2])
          mark_used(arguments[3])
          mark_used(arguments[4])
          mark_used(arguments[5])
        end
      end

      # mark key method and value method for options_from_collection_for_select and
      # option_groups_from_collection_for_select.
      add_callback :start_method_add_arg do |node|
        arguments = node.arguments.all
        case node.message.to_s
        when 'options_from_collection_for_select'
          mark_used(arguments[1])
          mark_used(arguments[2])
        when 'option_groups_from_collection_for_select'
          mark_used(arguments[1])
          mark_used(arguments[2])
          mark_used(arguments[3])
          mark_used(arguments[4])
        end
      end

      # get all unused methods at the end of review process.
      add_callback :after_check do
        @model_methods.get_all_unused_methods.each do |method|
          if !excepted?(method) && method.method_name !~ /=$/
            add_error "remove unused methods (#{method.class_name}##{method.method_name})", method.file, method.line_number
          end
        end
      end

      protected

        def methods
          @model_methods
        end

        def internal_except_methods
          %w(
            initialize
            validate validate_each validate_on_create validate_on_update
            human_attribute_name assign_attributes attributes attribute
            to_xml to_json as_json to_param
            before_save before_create before_update before_destroy after_save after_create
            after_update after_destroy after_find after_initialize
            method_missing
            table_name module_prefix
          ).map { |method_name| "*\##{method_name}" }
        end
    end
  end
end
