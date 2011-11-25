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

      interesting_nodes :class
      interesting_files CONTROLLER_FILES

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
    end
  end
end
