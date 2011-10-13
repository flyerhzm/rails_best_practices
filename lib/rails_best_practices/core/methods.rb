# encoding: utf-8
module RailsBestPractices
  module Core
    class Methods
      def initialize
        @methods = {}
        @possible_methods = {}
      end

      def add_method(model_name, method_name, meta={}, access_control="public")
        methods(model_name) << Method.new(model_name, method_name, access_control, meta)
        if access_control == "public"
          @possible_methods[method_name] = false
        end
      end

      def get_methods(model_name, access_control=nil)
        if access_control
          methods(model_name).select { |method| method.access_control == access_control }
        else
          methods(model_name)
        end
      end

      def has_method?(model_name, method_name, access_control=nil)
        if access_control
          !!methods(model_name).find { |method| method.method_name == method_name && method.access_control == access_control }
        else
          !!methods(model_name).find { |method| method.method_name == method_name }
        end
      end

      def possible_used(method_name)
        @possible_methods[method_name] = true
      end

      def get_method(model_name, method_name, access_control=nil)
        if access_control
          methods(model_name).find { |method| method.method_name == method_name && method.access_control == access_control }
        else
          methods(model_name).find { |method| method.method_name == method_name }
        end
      end

      def get_all_unused_methods(access_control=nil)
        @methods.inject([]) { |unused_methods, (model_name, methods)|
          unused_methods += if access_control
            methods.select { |method| method.access_control == access_control && !method.used }
          else
            methods.select { |method| !method.used }
          end
        }.reject { |method| @possible_methods[method.method_name] }
      end

      private
        def methods(model_name)
          @methods[model_name] ||= []
        end
    end

    class Method
      attr_reader :access_control, :class_name, :method_name, :used, :file, :line

      def initialize(class_name, method_name, access_control, meta)
        @class_name = class_name
        @method_name = method_name
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

