# encoding: utf-8
# frozen_string_literal: true

module RailsBestPractices
  module Core
    # Method container.
    class Methods
      def initialize
        @methods = {}
        @possible_methods = {}
      end

      # Add a method.
      #
      # @param [String] class name
      # @param [String] method name
      # @param [Hash] method meta, file and line, {"file" => "app/models/post.rb", "line_number" => 5}
      # @param [String] access control, public, protected or private
      def add_method(class_name, method_name, meta={}, access_control='public')
        return if class_name == ''
        return if has_method?(class_name, method_name)
        methods(class_name) << Method.new(class_name, method_name, access_control, meta)
        if access_control == 'public'
          @possible_methods[method_name] = false
        end
      end

      # Get methods of a class.
      #
      # @param [String] class name
      # @param [String] access control
      # @return [Array] all methods of a class for such access control, if access control is nil, return all public/protected/private methods
      def get_methods(class_name, access_control=nil)
        if access_control
          methods(class_name).select { |method| method.access_control == access_control }
        else
          methods(class_name)
        end
      end

      # If a class has a method.
      #
      # @param [String] class name
      # @param [String] method name
      # @param [String] access control
      # @return [Boolean] has a method or not
      def has_method?(class_name, method_name, access_control=nil)
        if access_control
          !!methods(class_name).find { |method| method.method_name == method_name && method.access_control == access_control }
        else
          !!methods(class_name).find { |method| method.method_name == method_name }
        end
      end

      # Mark parent class' method as used.
      #
      # @param [String] class name
      # @param [String] method name
      def mark_parent_class_method_used(class_name, method_name)
        klass = Prepares.klasses.find { |klass| klass.to_s == class_name }
        if klass && klass.extend_class_name
          mark_parent_class_method_used(klass.extend_class_name, method_name)
          method = get_method(klass.extend_class_name, method_name)
          method.mark_used if method
        end
      end

      # Mark sub classes' method as used.
      #
      # @param [String] class name
      # @param [String] method name
      def mark_subclasses_method_used(class_name, method_name)
        Prepares.klasses.select { |klass| klass.extend_class_name == class_name }.each do |klass|
          mark_subclasses_method_used(klass.to_s, method_name)
          method = get_method(klass.to_s, method_name)
          method.mark_used if method
        end
      end

      # Mark the method as public.
      #
      # @param [String] class name
      # @param [String] method name
      def mark_publicize(class_name, method_name)
        method = get_method(class_name, method_name)
        method.publicize if method
      end

      # Mark parent classs' method as public.
      #
      # @param [String] class name
      # @param [String] method name
      def mark_parent_class_methods_publicize(class_name, method_name)
        klass = Prepares.klasses.find { |klass| klass.to_s == class_name }
        if klass && klass.extend_class_name
          mark_parent_class_methods_publicize(klass.extend_class_name, method_name)
          mark_publicize(class_name, method_name)
        end
      end

      # Remomber the method name, the method is probably be used for the class' public method.
      #
      # @param [String] method name
      def possible_public_used(method_name)
        @possible_methods[method_name] = true
      end

      # Get a method in a class.
      #
      # @param [String] class name
      # @param [String] method name
      # @param [String] access control
      # @return [Method] Method object
      def get_method(class_name, method_name, access_control=nil)
        if access_control
          methods(class_name).find { |method| method.method_name == method_name && method.access_control == access_control }
        else
          methods(class_name).find { |method| method.method_name == method_name }
        end
      end

      # Get all unused methods.
      #
      # @param [String] access control
      # @return [Array] array of Method
      def get_all_unused_methods(access_control=nil)
        @methods.inject([]) { |unused_methods, (class_name, methods)|
          unused_methods += if access_control
            methods.select { |method| method.access_control == access_control && !method.used }
          else
            methods.select { |method| !method.used }
          end
        }.reject { |method| method.access_control == 'public' && @possible_methods[method.method_name] }
      end

      private

        # Methods of a class.
        #
        # @param [String] class name
        # @return [Array] array of methods
        def methods(class_name)
          @methods[class_name] ||= []
        end
    end

    # Method info includes class name, method name, access control, file, line_number, used.
    class Method
      attr_reader :access_control, :class_name, :method_name, :used, :file, :line_number

      def initialize(class_name, method_name, access_control, meta)
        @class_name = class_name
        @method_name = method_name
        @file = meta['file']
        @line_number = meta['line_number']
        @access_control = access_control
        @used = false
      end

      # Mark the method as used.
      def mark_used
        @used = true
      end

      # Mark the method as public
      def publicize
        @access_control = 'public'
      end

    end
  end
end

