# encoding: utf-8
module RailsBestPractices
  module Core
    class Methods
      def initialize
        @methods = {}
      end

      def add_method(model_name, method_name, access_control="public")
        methods(model_name, access_control) << method_name
      end

      def get_methods(model_name, access_control="public")
        methods(model_name, access_control)
      end

      def has_method?(model_name, method_name, access_control="public")
        methods(model_name, access_control).include? method_name
      end

      private
        def methods(model_name, access_control)
          @methods[model_name] ||= {}
          @methods[model_name][access_control] ||= []
        end
    end
  end
end

