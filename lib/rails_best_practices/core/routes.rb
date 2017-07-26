# encoding: utf-8
module RailsBestPractices
  module Core
    class Routes < Array
      # add a route.
      #
      # @param [Array] namesapces
      # @param [String] controller name
      # @param [String] action name
      def add_route(namespaces, controller_name, action_name)
        if namespaces.present? || controller_name.present?
          self << Route.new(namespaces, controller_name, action_name)
        end
      end
    end

    class Route
      attr_reader :namespaces, :controller_name, :action_name

      def initialize(namespaces, controller_name, action_name)
        @namespaces = namespaces

        # mappings can be specified by e.g.
        #   post 'some/:pattern' => 'controller#action'
        if action_name.is_a?(String) && action_name =~ /\A(\w+)#(\w+)\z/
          controller_name = $1
          action_name = $2
        end

        if controller_name
          entities = controller_name.split('/')
          @namespaces += entities[0..-2] if entities.size > 1
          @controller_name = entities.last
        end
        @action_name = action_name
      end

      def controller_name_with_namespaces
        if controller_name
          namespaces.map { |namespace| "#{namespace.camelize}::" }.join("") + "#{controller_name.camelize}Controller"
        else
          namespaces.map { |namespace| namespace.camelize }.join("::") + "Controller"
        end
      end

      def to_s
        "#{controller_name_with_namespaces}\##{action_name}"
      end
    end
  end
end
