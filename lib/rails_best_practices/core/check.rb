# frozen_string_literal: true

module RailsBestPractices
  module Core
    # A Check class that takes charge of checking the sexp.
    class Check < CodeAnalyzer::Checker
      ALL_FILES = /.*/
      CONTROLLER_FILES = /app\/(controllers|cells)\/.*\.rb$/
      MIGRATION_FILES = /db\/migrate\/.*\.rb$/
      MODEL_FILES = /app\/models\/.*\.rb$/
      MAILER_FILES = /app\/models\/.*mailer\.rb$|app\/mailers\/.*\.rb/
      VIEW_FILES = /app\/(views|cells)\/.*\.(erb|haml|slim|builder|rxml)$/
      PARTIAL_VIEW_FILES = /app\/(views|cells)\/.*\/_.*\.(erb|haml|slim|builder|rxml)$/
      ROUTE_FILES = /config\/routes.*\.rb/
      SCHEMA_FILE = /db\/schema\.rb/
      HELPER_FILES = /app\/helpers\/.*\.rb$/
      DEPLOY_FILES = /config\/deploy.*\.rb/
      CONFIG_FILES = /config\/(application|environment|environments\/.*)\.rb/
      INITIALIZER_FILES = /config\/initializers\/.*\.rb/
      CAPFILE = /Capfile/
      GEMFILE_LOCK = /Gemfile\.lock/

      SKIP_FILES = /db\/schema.rb/

      def initialize(options = {})
        options.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end

      # check if the check will need to parse the node file.
      #
      # @param [String] the file name of node.
      # @return [Boolean] true if the check will need to parse the file.
      def parse_file?(node_file)
        is_interesting_file?(node_file) and !is_ignored?(node_file)
      end

      def is_interesting_file?(node_file)
        interesting_files.any? do |pattern|
          if pattern == ALL_FILES
            node_file =~ pattern && node_file !~ SKIP_FILES
          else
            node_file =~ pattern
          end
        end
      end

      def is_ignored?(node_file)
        regex_ignored_files.map { |r| !!r.match(node_file) }.inject(:|)
      end

      def regex_ignored_files
        @regex_ignored_files ||= Array(@ignored_files).map { |pattern| Regexp.new(pattern) }
      end

      # add error if source code violates rails best practice.
      #
      # @param [String] message, is the string message for violation of the rails best practice
      # @param [String] filename, is the filename of source code
      # @param [Integer] line_number, is the line number of the source code which is reviewing
      def add_error(message, filename = @node.file, line_number = @node.line_number)
        errors << RailsBestPractices::Core::Error.new(
          filename: filename,
          line_number: line_number,
          message: message,
          type: self.class.to_s,
          url: url
        )
      end

      # errors that violate the rails best practices.
      def errors
        @errors ||= []
      end

      # default url is empty.
      #
      # @return [String] the url of rails best practice
      def url
        self.class.url
      end

      # method_missing to catch all start and end process for each node type, like
      #
      #     start_def
      #     end_def
      #     start_call
      #     end_call
      #
      # if there is a "debug" method defined in check, each node will be output.
      def method_missing(method_name, *args)
        if method_name.to_s =~ /^start_/
          p args if respond_to?(:debug)
        elsif method_name.to_s =~ /^end_/
          # nothing to do
        else
          super
        end
      end

      class <<self
        def url(url = nil)
          url ?  @url = url : @url
        end

        def debug?
          @debug == true
        end

        def debug
          @debug = true
        end
      end

      # Helper to parse the class name.
      module Classable
        def self.included(base)
          base.class_eval do
            interesting_nodes :module, :class

            # remember module name
            add_callback :start_module do |node|
              classable_modules << node.module_name.to_s
            end

            # end of the module.
            add_callback :end_module do |node|
              classable_modules.pop
            end

            # remember the class name
            add_callback :start_class do |node|
              base_class_name = node.base_class.is_a?(CodeAnalyzer::Nil) ? nil : node.base_class.to_s
              @klass = Core::Klass.new(node.class_name.to_s, base_class_name, classable_modules)
              klasses << @klass
            end

            # end of the class
            add_callback :end_class do |node|
              klasses.pop
              # @klass = nil
            end
          end
        end

        # get the current class name.
        def current_class_name
          @klass.to_s
        end

        # get the current extend class name.
        def current_extend_class_name
          @klass.extend_class_name
        end

        # modules.
        def classable_modules
          @class_modules ||= []
        end

        def klasses
          @klasses ||= []
        end
      end

      # Helper to parse the module name.
      module Moduleable
        def self.included(base)
          base.class_eval do
            interesting_nodes :module

            # remember module name
            add_callback :start_module do |node|
              moduleable_modules << node.module_name.to_s
            end

            # end of module
            add_callback :end_module do |node|
              moduleable_modules.pop
            end
          end
        end

        # get the current module name.
        def current_module_name
          moduleable_modules.join('::')
        end

        # modules.
        def moduleable_modules
          @moduleable_modules ||= []
        end
      end

      # Helper to add callbacks to mark the methods are used.
      module Callable
        def self.included(base)
          base.class_eval do
            interesting_nodes :call, :fcall, :var_ref, :vcall, :command_call, :command, :alias, :bare_assoc_hash, :method_add_arg

            # remembe the message of call node.
            add_callback :start_call do |node|
              mark_used(node.message)
            end

            # remembe the message of fcall node.
            add_callback :start_fcall do |node|
              mark_used(node.message)
            end

            # remembe name of var_ref node.
            add_callback :start_var_ref do |node|
              mark_used(node)
            end

            # remembe name of vcall node.
            add_callback :start_vcall do |node|
              mark_used(node)
            end

            # skip start_command callback for these nodes
            def skip_command_callback_nodes
              []
            end

            # remember the message of command node.
            # remember the argument of alias_method and alias_method_chain as well.
            add_callback :start_command do |node|
              case node.message.to_s
              when *skip_command_callback_nodes
                # nothing
              when 'alias_method'
                mark_used(node.arguments.all[1])
              when 'alias_method_chain'
                method, feature = *node.arguments.all.map(&:to_s)
                call_method("#{method}_with_#{feature}")
              when /^(before|after)_/
                node.arguments.all.each { |argument| mark_used(argument) }
              else
                mark_used(node.message)
                last_argument = node.arguments.all.last
                if last_argument.present? && :bare_assoc_hash == last_argument.sexp_type
                  last_argument.hash_values.each { |argument_value| mark_used(argument_value) }
                end
              end
            end

            # remembe the message of command call node.
            add_callback :start_command_call do |node|
              mark_used(node.message)
            end

            # remember the old method of alias node.
            add_callback :start_alias do |node|
              mark_used(node.old_method)
            end

            # remember hash values for hash key "methods".
            #
            #     def to_xml(options = {})
            #       super options.merge(exclude: :visible, methods: [:is_discussion_conversation])
            #     end
            add_callback :start_bare_assoc_hash do |node|
              if node.hash_keys.include? 'methods'
                mark_used(node.hash_value('methods'))
              end
            end

            # remember the first argument for try and send method.
            add_callback :start_method_add_arg do |node|
              case node.message.to_s
              when 'try'
                mark_used(node.arguments.all.first)
              when 'send'
                if %i[symbol_literal string_literal].include?(node.arguments.all.first.sexp_type)
                  mark_used(node.arguments.all.first)
                end
              else
                # nothing
              end
            end

            private

              def mark_used(method_node)
                return if method_node == :call
                if :bare_assoc_hash == method_node.sexp_type
                  method_node.hash_values.each { |value_node| mark_used(value_node) }
                elsif :array == method_node.sexp_type
                  method_node.array_values.each { |value_node| mark_used(value_node) }
                else
                  method_name = method_node.to_s
                end
                call_method(method_name)
              end

              def call_method(method_name, class_name = nil)
                name ||= respond_to?(:current_class_name) ? current_class_name : current_module_name
                if methods.has_method?(name, method_name)
                  methods.get_method(name, method_name).mark_used
                end
                methods.mark_parent_class_method_used(name, method_name)
                methods.mark_subclasses_method_used(name, method_name)
                methods.possible_public_used(method_name)
              end
          end
        end
      end

      # Helper to indicate if the controller is inherited from InheritedResources.
      module InheritedResourcesable
        def self.included(base)
          base.class_eval do
            interesting_nodes :class, :var_ref, :vcall
            interesting_files CONTROLLER_FILES

            # check if the controller is inherit from InheritedResources::Base.
            add_callback :start_class do |node|
              if 'InheritedResources::Base' == current_extend_class_name
                @inherited_resources = true
              end
            end

            # check if there is a DSL call inherit_resources.
            add_callback :start_var_ref do |node|
              if 'inherit_resources' == node.to_s
                @inherited_resources = true
              end
            end

            # check if there is a DSL call inherit_resources.
            add_callback :start_vcall do |node|
              if 'inherit_resources' == node.to_s
                @inherited_resources = true
              end
            end
          end
        end
      end

      # Helper to check except methods.
      module Exceptable
        def self.included(base)
          base.class_eval do
            def except_methods
              @except_methods + internal_except_methods
            end

            # check if the method is in the except methods list.
            def excepted?(method)
              is_ignored?(method.file) ||
              except_methods.any? { |except_method| Exceptable.matches method, except_method }
            end

            def internal_except_methods
              raise NoMethodError.new 'no method internal_except_methods'
            end
          end
        end

        def self.matches(method, except_method)
          class_name, method_name = except_method.split('#')

          method_name = '.*' if method_name == '*'
          method_expression = Regexp.new method_name
          matched = method.method_name =~ method_expression

          if matched
            class_name = '.*' if class_name == '*'
            class_expression = Regexp.new class_name

            class_names = Prepares.klasses
                                  .select { |klass| klass.class_name == method.class_name }
                                  .map(&:extend_class_name)
                                  .compact

            class_names.unshift method.class_name
            matched = class_names.any? { |name| name =~ class_expression }
          end

          !!matched
        end
      end

      # Helper to parse the access control.
      module Accessable
        def self.included(base)
          base.class_eval do
            interesting_nodes :var_ref, :vcall, :class, :module

            # remember the current access control for methods.
            add_callback :start_var_ref do |node|
              if %w[public protected private].include? node.to_s
                @access_control = node.to_s
              end
            end

            # remember the current access control for methods.
            add_callback :start_vcall do |node|
              if %w[public protected private].include? node.to_s
                @access_control = node.to_s
              end
            end

            # set access control to "public" by default.
            add_callback :start_class do |node|
              @access_control = 'public'
            end

            # set access control to "public" by default.
            add_callback :start_module do |node|
              @access_control = 'public'
            end
          end

          # get the current acces control.
          def current_access_control
            @access_control
          end
        end
      end
    end
  end
end
