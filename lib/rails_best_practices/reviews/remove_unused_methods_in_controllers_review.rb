# encoding: utf-8
module RailsBestPractices
  module Reviews
    # Find out unused methods in controllers.
    #
    # Implementation:
    #
    # Review process:
    #   remember all method calls in controllers,
    #   if they are not defined in routes,
    #   and they are not called in controllers,
    #   then they are the unused methods in controllers.
    class RemoveUnusedMethodsInControllersReview < Review
      include Classable
      include Moduleable
      include Callable
      include Exceptable
      include InheritedResourcesable

      interesting_nodes :class, :command, :method_add_arg, :assign
      interesting_files CONTROLLER_FILES, VIEW_FILES, HELPER_FILES

      INHERITED_RESOURCES_METHODS = %w(resource collection begin_of_association_chain build_resource)

      def initialize(options={})
        super
        @controller_methods = Prepares.controller_methods
        @routes = Prepares.routes
        @inherited_resources = false
      end

      # mark custom inherited_resources methods as used.
      add_callback :end_class do |node|
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
      add_callback :start_command, :start_method_add_arg do |node|
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
        when "layout"
          first_argument = node.arguments.all.first
          if first_argument.sexp_type == :symbol_literal
            mark_used(first_argument)
          end
        when "helper_method"
          node.arguments.all.each { |argument| mark_publicize(argument.to_s) }
        when "delegate"
          last_argument = node.arguments.all.last
          if :bare_assoc_hash == last_argument.sexp_type && "controller" == last_argument.hash_value("to").to_s
            controller_name = current_module_name.sub("Helper", "Controller")
            node.arguments.all[0..-2].each { |method| mark_publicize(method.to_s, controller_name) }
          end
        else
          # nothing
        end
      end

      # mark assignment as used, like current_user = @user
      add_callback :start_assign do |node|
        if :var_field == node.left_value.sexp_type
          call_method "#{node.left_value}=", current_class_name
        end
      end

      # get all unused methods at the end of review process.
      add_callback :after_check do
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
            add_error "remove unused methods (#{method.class_name}##{method.method_name})", method.file, method.line_number
          end
        end
      end

      protected
        def methods
          @controller_methods
        end

        def internal_except_methods
          %w(rescue_action).map { |method_name| "*\##{method_name}" } +
            %w(Devise::OmniauthCallbacksController).map { |controller_name| "#{controller_name}#*" }
        end

        def mark_publicize(method_name, class_name=current_class_name)
          @controller_methods.mark_publicize(class_name, method_name)
          @controller_methods.mark_parent_class_methods_publicize(class_name, method_name)
        end
    end
  end
end
