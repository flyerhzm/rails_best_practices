# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remembber routes.
    class RoutePrepare < Core::Check
      interesting_nodes :command, :command_call, :method_add_block
      interesting_files ROUTE_FILES

      RESOURCES_ACTIONS = %w(index show new create edit update destroy)
      RESOURCE_ACTIONS = %w(show new create edit update destroy)

      def initialize
        @routes = Prepares.routes
        @namespaces = []
      end

      # remember route for rails3.
      def start_command(node)
        case node.message.to_s
        when "resources"
          add_resources_routes(node)
        when "resource"
          add_resource_routes(node)
        when "get", "post", "put", "delete"
          first_argument = node.arguments.all.first
          if current_controller_name.present?
            action_name = first_argument.to_s
            @routes.add_route(current_namespaces, current_controller_name, action_name)
          else
            if :bare_assoc_hash == first_argument.sexp_type
              route_node = first_argument.hash_values.first
              controller_name, action_name = route_node.to_s.split('#')
            else
              controller_name, action_name = first_argument.to_s.split('/')
            end
            @routes.add_route(current_namespaces, controller_name.underscore, action_name)
          end
        when "match", "root"
          options = node.arguments.all.last
          return if :string_literal == options.sexp_type
          if options.hash_value("controller").present?
            return if :regexp_literal == options.hash_value("controller").sexp_type
            controller_name = options.hash_value("controller").to_s
            action_name = options.hash_value("action").present? ? options.hash_value("action").to_s : "*"
            @routes.add_route(current_namespaces, controller_name, action_name)
          else
            route_node = options.hash_values.find { |value_node| :string_literal == value_node.sexp_type && value_node.to_s.include?('#') }
            if route_node.present?
              controller_name, action_name = route_node.to_s.split('#')
              @routes.add_route(current_namespaces, controller_name.underscore, action_name)
            end
          end
        else
          # nothing to do
        end
      end

      # remember route for rails2.
      def start_command_call(node)
        case node.message.to_s
        when "resources"
          add_resources_routes(node)
        when "resource"
          add_resource_routes(node)
        when "namespace"
          # nothing to do
        else
          options = node.arguments.all.last
          if options.hash_value("controller").present?
            @controller_name = options.hash_value("controller").to_s
          end
          action_name = options.hash_value("action").present? ? options.hash_value("action").to_s : "*"
          @routes.add_route(current_namespaces, current_controller_name, action_name)
        end
      end

      # remember the namespace.
      def start_method_add_block(node)
        if "namespace" == node.message.to_s
          @namespaces << node.arguments.all.first.to_s
        elsif "with_options" == node.message.to_s
          argument = node.arguments.all.last
          if :bare_assoc_hash == argument.sexp_type && argument.hash_value("controller").present?
            @controller_name = argument.hash_value("controller").to_s
          end
        end
      end

      # end of namespace call.
      def end_method_add_block(node)
        if "namespace" == node.message.to_s
          @namespaces.pop
        end
      end

      [:resources, :resource].each do |route_name|
        class_eval <<-EOF
        def add_#{route_name}_routes(node)
          resource_names = node.arguments.all.select { |argument| :symbol_literal == argument.sexp_type }
          resource_names.each do |resource_name|
            @controller_name = node.arguments.all.first.to_s
            options = node.arguments.all.last
            if options.hash_value("controller").present?
              @controller_name = options.hash_value("controller").to_s
            end
            action_names = if options.hash_value("only").present?
                             get_#{route_name}_actions(options.hash_value("only").to_object)
                           elsif options.hash_value("except").present?
                             self.class.const_get(:#{route_name.to_s.upcase}_ACTIONS) - get_#{route_name}_actions(options.hash_value("except").to_object)
                           else
                             self.class.const_get(:#{route_name.to_s.upcase}_ACTIONS)
                           end
            action_names.each do |action_name|
              @routes.add_route(current_namespaces, current_controller_name, action_name)
            end

            member_routes = options.hash_value("member")
            if member_routes.present?
              action_names = :array == member_routes.sexp_type ? member_routes.to_object : member_routes.hash_keys
              action_names.each do |action_name|
                @routes.add_route(current_namespaces, current_controller_name, action_name)
              end
            end

            collection_routes = options.hash_value("collection")
            if collection_routes.present?
              action_names = :array == collection_routes.sexp_type ? collection_routes.to_object : collection_routes.hash_keys
              action_names.each do |action_name|
                @routes.add_route(current_namespaces, current_controller_name, action_name)
              end
            end
          end
        end

        def get_#{route_name}_actions(action_names)
          case action_names
          when "all"
            self.class.const_get(:#{route_name.to_s.upcase}_ACTIONS)
          when "none"
            []
          else
            Array(action_names)
          end
        end

        def add_customize_routes
        end
        EOF
      end

      def current_namespaces
        @namespaces.dup
      end

      def current_controller_name
        @controller_name
      end
    end
  end
end
