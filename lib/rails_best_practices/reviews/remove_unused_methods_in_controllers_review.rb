# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    class RemoveUnusedMethodsInControllersReview < Review
      include Klassable
      include Completeable
      include Callable
      include Exceptable
      include InheritedResourcesable

      interesting_nodes :class, :command, :method_add_arg
      interesting_files CONTROLLER_FILES, VIEW_FILES

      INHERITED_RESOURCES_METHODS = %w(resource collection begin_of_association_chain build_resource)

      def initialize(options={})
        super
        @controller_methods = Prepares.controller_methods
        @routes = Prepares.routes
        @inherited_resources = false
      end

      # mark custom inherited_resources methods as used.
      def end_class(node)
        if @inherited_resources
          INHERITED_RESOURCES_METHODS.each do |method|
            call_method(method)
          end
        end
      end

      # skip render and around_filter nodes for start_command callbacks.
      def skip_command_callback_nodes
        %w(render_cell render around_filter)
      end

      # mark corresponding action as used for cells' render and render_call.
      def start_command(node)
        case node.message.to_s
        when "render_cell"
          controller_name, action_name, _ = *node.arguments.all.map(&:to_s)
          call_method(action_name, "#{controller_name}_cell".classify)
        when "render"
          first_argument = node.arguments.all.first
          if first_argument.present? && first_argument.hash_value("state").present?
            action_name = first_argument.hash_value("state").to_s
            call_method(action_name, current_class_name)
          end
        when "around_filter"
          node.arguments.all.each { |argument| mark_used(argument) }
        when "helper_method"
          node.arguments.all.each { |argument| mark_possible_used(argument.to_s) }
        else
          # nothing
        end
      end

      alias :start_method_add_arg :start_command

      # get all unused methods at the end of review process.
      def on_complete
        @routes.each do |route|
          if "*" == route.action_name
            action_names = @controller_methods.get_methods(route.controller_name_with_namespaces).map(&:method_name)
            action_names.each { |action_name| call_method(action_name, route.controller_name_with_namespaces) }
          else
            call_method(route.action_name, route.controller_name_with_namespaces)
          end
        end
        @controller_methods.get_all_unused_methods.each do |method|
          if !excepted?(method)
            add_error "remove unused methods (#{method.class_name}##{method.method_name})", method.file, method.line
          end
        end
      end

      protected
        def methods
          @controller_methods
        end

        def internal_except_methods
          %w(rescue_action).map { |method_name| "*\##{method_name}" }
        end

        def mark_possible_used(method_name)
          @controller_methods.get_method(current_class_name, method_name).access_control = "public"
          @controller_methods.possible_public_used(method_name)
        end
    end
  end
end
