# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review a route file to make sure all auto-generated routes have corresponding actions in controller.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/86-restrict-auto-generated-routes
    #
    # Implementation:
    #
    # Review process:
    #   check all resources and resource method calls,
    #   compare the generated routes and corresponding actions in controller,
    #   if there is a route generated, but there is not action in that controller,
    #   then you should restrict your routes.
    class RestrictAutoGeneratedRoutesReview < Review
      interesting_nodes :command, :command_call, :method_add_block
      interesting_files ROUTE_FILES

      RESOURCE_METHODS = ["show", "new", "create", "edit", "update", "destroy"]
      RESOURCES_METHODS = RESOURCE_METHODS + ["index"]

      def url
        "http://rails-bestpractices.com/posts/86-restrict-auto-generated-routes"
      end

      def initialize
        super
        @namespaces = []
        @resource_controllers = []
      end

      # check if the generated routes have the corresponding actions in controller for rails3 routes.
      def start_command(node)
        if "resources" == node.message.to_s
          check_resources(node)
          @resource_controllers << node.arguments.all.first.to_s
        elsif "resource" == node.message.to_s
          check_resource(node)
          @resource_controllers << node.arguments.all.first.to_s
        end
      end

      def end_command(node)
        if "resources" == node.message.to_s
          @resource_controllers.pop
        elsif "resource" == node.message.to_s
          @resource_controllers.pop
        end
      end

      # remember the namespace.
      def start_method_add_block(node)
        case node.message.to_s
        when "namespace"
          return unless check_method_add_block?(node)
          @namespaces << node.arguments.all.first.to_s
        when "resources", "resource"
          return unless check_method_add_block?(node)
          @resource_controllers << node.arguments.all.first.to_s
        else
        end
      end

      # end of namespace call.
      def end_method_add_block(node)
        return unless check_method_add_block?(node)

        case node.message.to_s
        when "namespace"
          @namespaces.pop
        when "resources", "resource"
          @resource_controllers.pop
        end
      end

      def check_method_add_block?(node)
        :command == node[1].sexp_type || (:command_call == node[1].sexp_type && "map" != node.subject.to_s)
      end

      # check if the generated routes have the corresponding actions in controller for rails2 routes.
      alias_method :start_command_call, :start_command

      private
        # check resources call, if the routes generated by resources does not exist in the controller.
        def check_resources(node)
          controller_name = controller_name(node)
          return unless Prepares.controllers.include? controller_name
          resources_methods = resources_methods(node)
          unless resources_methods.all? { |meth| Prepares.controller_methods.has_method?(controller_name, meth) }
            only_methods = (resources_methods & Prepares.controller_methods.get_methods(controller_name).map(&:method_name)).map { |meth| ":#{meth}" }.join(", ")
            add_error "restrict auto-generated routes #{friendly_route_name(node)} (only: [#{only_methods}])"
          end
        end

        # check resource call, if the routes generated by resources does not exist in the controller.
        def check_resource(node)
          controller_name = controller_name(node)
          return unless Prepares.controllers.include? controller_name
          resource_methods = resource_methods(node)
          unless resource_methods.all? { |meth| Prepares.controller_methods.has_method?(controller_name, meth) }
            only_methods = (resource_methods & Prepares.controller_methods.get_methods(controller_name).map(&:method_name)).map { |meth| ":#{meth}" }.join(", ")
            add_error "restrict auto-generated routes #{friendly_route_name(node)} (only: [#{only_methods}])"
          end
        end

        # get the controller name.
        def controller_name(node)
          if option_with_hash(node)
            option_node = node.arguments.all[1]
            if hash_key_exist?(option_node,"controller")
              name = option_node.hash_value("controller").to_s
            else
              name = node.arguments.all.first.to_s.gsub("::", "").tableize
            end
          else
            name = node.arguments.all.first.to_s.gsub("::", "").tableize
          end
          namespaced_class_name(name)
        end

        # get the class name with namespace.
        def namespaced_class_name(name)
          class_name = "#{name.split("/").map(&:camelize).join("::")}Controller"
          if @namespaces.empty?
            class_name
          else
            @namespaces.map { |namespace| "#{namespace.camelize}::" }.join("") + class_name
          end
        end

        # get the route actions that should be generated by resources call.
        def resources_methods(node)
          methods = RESOURCES_METHODS

          if option_with_hash(node)
            option_node = node.arguments.all[1]
            if hash_key_exist?(option_node, "only")
              option_node.hash_value("only").to_s == "none" ? [] : Array(option_node.hash_value("only").to_object)
            elsif hash_key_exist?(option_node, "except")
              option_node.hash_value("except").to_s == "all" ? [] : (methods - Array(option_node.hash_value("except").to_object))
            else
              methods
            end
          else
            methods
          end
        end

        # get the route actions that should be generated by resource call.
        def resource_methods(node)
          methods = RESOURCE_METHODS

          if option_with_hash(node)
            option_node = node.arguments.all[1]
            if hash_key_exist?(option_node, "only")
              option_node.hash_value("only").to_s == "none" ? [] : Array(option_node.hash_value("only").to_object)
            elsif hash_key_exist?(option_node, "except")
              option_node.hash_value("except").to_s == "all" ? [] : (methods - Array(option_node.hash_value("except").to_object))
            else
              methods
            end
          else
            methods
          end
        end

        def option_with_hash(node)
          node.arguments.all.size > 1 && :bare_assoc_hash == node.arguments.all[1].sexp_type
        end

        def hash_key_exist?(node, key)
          node.hash_keys && node.hash_keys.include?(key)
        end

        def friendly_route_name(node)
          if @resource_controllers.last == node.arguments.to_s
            [@namespaces.join("/"), @resource_controllers.join("/")].delete_if(&:blank?).join("/")
          else
            [@namespaces.join("/"), @resource_controllers.join("/"), node.arguments.to_s].delete_if(&:blank?).join("/")
          end
        end
    end
  end
end
