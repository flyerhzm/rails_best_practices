# encoding: utf-8
module RailsBestPractices
  module Core
    class Methods
      def initialize
        @methods = {}
      end

      def add_method(model_name, method_name, meta={}, access_control="public")
        methods(model_name) << Method.new(method_name, access_control, meta)
      end

      def get_methods(model_name, access_control="public")
        methods(model_name).select { |method| method.access_control == access_control }
      end

      def has_method?(model_name, method_name, access_control="public")
        !!methods(model_name).find { |method| method.name == method_name && method.access_control == access_control }
      end

      def get_method(model_name, method_name, access_control="public")
        methods(model_name).find { |method| method.name == method_name && method.access_control == access_control }
      end

      def mark_used(model_name, method_name, access_control="public")
        get_method(model_name, method_name, access_control).mark_used
      end

      private
        def methods(model_name)
          @methods[model_name] ||= []
        end
    end

    class Method
      attr_reader :access_control, :name

      def initialize(method_name, access_control, meta)
        @name = method_name
        @file = meta["file"]
        @line = meta["line"]
        @access_control = access_control
        @used = false
      end

      def mark_used
        @used = true
      end
    end
  end
end

