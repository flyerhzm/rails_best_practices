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
        when "match", "root"
          options = node.arguments.all.first
          route_node = options.hash_values.detect { |value_node| :string_literal == value_node.sexp_type && value_node.to_s.include?('#') }
          controller_name, action_name = route_node.to_s.split('#')
          @routes.add_route(@namespaces, controller_name.underscore, action_name)
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
          controller_name = options.hash_value("controller").to_s
          action_name = options.hash_value("action").to_s
          @routes.add_route(@namespaces, controller_name, action_name)
        end
      end

      # remember the namespace.
      def start_method_add_block(node)
        if "namespace" == node.message.to_s
          @namespaces << node.arguments.all.first.to_s
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
          resource_name = node.arguments.all.first.to_s
          options = node.arguments.all.last
          action_names = if options.hash_value("only").present?
                           get_#{route_name}_actions(options.hash_value("only").to_object)
                         elsif options.hash_value("except").present?
                           self.class.const_get(:#{route_name.upcase}_ACTIONS) - get_#{route_name}_actions(options.hash_value("except").to_object)
                         else
                           self.class.const_get(:#{route_name.upcase}_ACTIONS)
                         end
          action_names.each do |action_name|
            @routes.add_route(@namespaces.dup, resource_name, action_name)
          end
        end

        def get_#{route_name}_actions(action_names)
          case action_names
          when "all"
            self.class.const_get(:#{route_name.upcase}_ACTIONS)
          when "none"
            []
          else
            action_names
          end
        end
        EOF
      end
    end
  end
end
