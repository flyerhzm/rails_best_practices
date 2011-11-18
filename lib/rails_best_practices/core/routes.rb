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
        self << Route.new(namespaces, controller_name, action_name)
      end
    end

    class Route
      attr_reader :namespaces, :controller_name, :action_name

      def initialize(namespaces, controller_name, action_name)
        @namespaces = namespaces
        @controller_name = controller_name
        @action_name = action_name
      end

      def to_s
        namespaces.map { |namespace| "#{namespace.camelize}::" }.join("") + "#{controller_name.camelize}Controller\##{action_name}"
      end
    end
  end
end
