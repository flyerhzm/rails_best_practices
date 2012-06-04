# encoding: utf-8
module RailsBestPractices
  module Core
    # A Check class that takes charge of checking the sexp.
    class Check
      ALL_FILES = /.*/
      CONTROLLER_FILES = /(controllers|cells)\/.*\.rb$/
      MIGRATION_FILES = /db\/migrate\/.*\.rb$/
      MODEL_FILES = /models\/.*\.rb$/
      MAILER_FILES = /models\/.*mailer\.rb$|mailers\/.*mailer\.rb/
      VIEW_FILES = /(views|cells)\/.*\.(erb|haml|slim|builder|rxml)$/
      PARTIAL_VIEW_FILES = /(views|cells)\/.*\/_.*\.(erb|haml|slim|builder|rxml)$/
      ROUTE_FILES = /config\/routes.*\.rb/
      SCHEMA_FILE = /db\/schema\.rb/
      HELPER_FILES = /helpers\/.*\.rb$/
      DEPLOY_FILES = /config\/deploy.*\.rb/
      CONFIG_FILES = /config\/(application|environment|environments\/.*)\.rb/

      def initialize(options={})
        options.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end

      # interesting nodes that the check will parse.
      def interesting_nodes
        self.class.interesting_nodes
      end

      # interesting files that the check will parse.
      def interesting_files
        self.class.interesting_files
      end

      # check if the check will need to parse the node file.
      #
      # @param [String] the file name of node.
      # @return [Boolean] true if the check will need to parse the file.
      def parse_file?(node_file)
        interesting_files.any? { |pattern| node_file =~ pattern }
      end

      # delegate to start_### according to the sexp_type, like
      #
      #     start_call
      #     start_def
      #
      # @param [Sexp] node
      def node_start(node)
        @node = node
        if self.class.debug?
          ap node
        end
        Array(self.class.callbacks["start_#{node.sexp_type}"]).each do |callback|
          self.instance_exec node, &callback
        end
        self.send("start_#{node.sexp_type}", node)
      end

      # delegate to end_### according to the sexp_type, like
      #
      #     end_call
      #     end_def
      #
      # @param [Sexp] node
      def node_end(node)
        @node = node
        self.send("end_#{node.sexp_type}", node)
        Array(self.class.callbacks["end_#{node.sexp_type}"]).each do |callback|
          self.instance_exec node, &callback
        end
      end

      def after_prepare; end
      def after_review; end

      # add error if source code violates rails best practice.
      #
      # @param [String] message, is the string message for violation of the rails best practice
      # @param [String] filename, is the filename of source code
      # @param [Integer] line_number, is the line number of the source code which is reviewing
      def add_error(message, filename = @node.file, line_number = @node.line)
        errors << RailsBestPractices::Core::Error.new(
          filename: filename,
          line_number: line_number,
          message: message,
          type: self.class.to_s,
          url: url
        )
      end

      # errors that vialote the rails best practices.
      def errors
        @errors ||= []
      end

      # default url is empty.
      #
      # @return [String] the url of rails best practice
      def url
        ""
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
        def interesting_nodes(*nodes)
          @interesting_nodes ||= []
          @interesting_nodes += nodes
          @interesting_nodes.uniq
        end

        def interesting_files(*file_patterns)
          @interesting_files ||= []
          @interesting_files += file_patterns
          @interesting_files.uniq
        end

        # callbacks for start_xxx and end_xxx.
        def callbacks
          @callbacks ||= {}
        end

        # add a callback.
        #
        # @param [String] name, callback name, can be start_xxx or end_xxx
        # @param [Proc] block, be executed when callbacks are called
        def add_callback(name, &block)
          callbacks[name] ||= []
          callbacks[name] << block
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
            add_callback "start_module" do |node|
              classable_modules << node.module_name.to_s
            end

            # end of the module.
            add_callback "end_module" do |node|
              classable_modules.pop
            end

            # remember the class anem
            add_callback "start_class" do |node|
              @klass = Core::Klass.new(node.class_name.to_s, node.base_class.to_s, classable_modules)
            end

            # end of the class
            add_callback "end_class" do |node|
              @klass = nil
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
          @class_moduels ||= []
        end
      end

      # Helper to parse the module name.
      module Moduleable
        def self.included(base)
          base.class_eval do
            interesting_nodes :module

            # remember module name
            add_callback "start_module" do |node|
              moduleable_modules << node.module_name.to_s
            end

            # end of module
            add_callback "end_module" do |node|
              moduleable_modules.pop
            end
          end
        end

        # get the current module name.
        def current_module_name
          moduleable_modules.join("::")
        end

        # modules.
        def moduleable_modules
          @moduleable_moduels ||= []
        end
      end

      # Helper to add callback after all files reviewed.
      module Afterable
        def self.included(base)
          base.class_eval do
            interesting_nodes :class
            interesting_files /rails_best_practices\.after_(prepare|review)/

            add_callback "end_class" do |node|
              if "RailsBestPractices::AfterPrepare" == node.class_name.to_s
                after_prepare
              elsif "RailsBestPractices::AfterReview" == node.class_name.to_s
                after_review
              end
            end
          end
        end
      end

      # Helper to add callbacks to mark the methods are used.
      module Callable
        def self.included(base)
          base.class_eval do
            interesting_nodes :call, :fcall, :var_ref, :vcall, :command_call, :command, :alias, :bare_assoc_hash, :method_add_arg

            # remembe the message of call node.
            add_callback "start_call" do |node|
              mark_used(node.message)
            end

            # remembe the message of fcall node.
            add_callback "start_fcall" do |node|
              mark_used(node.message)
            end

            # remembe name of var_ref node.
            add_callback "start_var_ref" do |node|
              mark_used(node)
            end

            # remembe name of vcall node.
            add_callback "start_vcall" do |node|
              mark_used(node)
            end

            # skip start_command callback for these nodes
            def skip_command_callback_nodes
              []
            end

            # remember the message of command node.
            # remember the argument of alias_method and alias_method_chain as well.
            add_callback "start_command" do |node|
              case node.message.to_s
              when *skip_command_callback_nodes
                # nothing
              when "alias_method"
                mark_used(node.arguments.all[1])
              when "alias_method_chain"
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
            add_callback "start_command_call" do |node|
              mark_used(node.message)
            end

            # remember the old method of alias node.
            add_callback "start_alias" do |node|
              mark_used(node.old_method)
            end

            # remember hash values for hash key "methods".
            #
            #     def to_xml(options = {})
            #       super options.merge(exclude: :visible, methods: [:is_discussion_conversation])
            #     end
            add_callback "start_bare_assoc_hash" do |node|
              if node.hash_keys.include? "methods"
                mark_used(node.hash_value("methods"))
              end
            end

            # remember the first argument for try and send method.
            add_callback "start_method_add_arg" do |node|
              case node.message.to_s
              when "try"
                mark_used(node.arguments.all.first)
              when "send"
                if [:symbol_literal, :string_literal].include?(node.arguments.all.first.sexp_type)
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

              def call_method(method_name, class_name=nil)
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
            add_callback "start_class" do |node|
              if "InheritedResources::Base" == current_extend_class_name
                @inherited_resources = true
              end
            end

            # check if there is a DSL call inherit_resources.
            add_callback "start_var_ref" do |node|
              if "inherit_resources" == node.to_s
                @inherited_resources = true
              end
            end

            # check if there is a DSL call inherit_resources.
            add_callback "start_vcall" do |node|
              if "inherit_resources" == node.to_s
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
              except_methods.any? do |except_method|
                class_name, method_name = except_method.split('#')
                (class_name == '*' && method_name == method.method_name) ||
                  (method_name == '*' && class_name == method.class_name) ||
                  (method_name == '*' && class_name == Prepares.klasses.find { |klass| klass.class_name == method.class_name }.try(:extend_class_name)) ||
                  (class_name == method.class_name && method_name == method.method_name)
              end
            end

            def internal_except_methods
              raise NoMethodError.new "no method internal_except_methods"
            end
          end
        end
      end

      # Helper to parse the access control.
      module Accessable
        def self.included(base)
          base.class_eval do
            interesting_nodes :var_ref, :vcall, :class, :module

            # remember the current access control for methods.
            add_callback "start_var_ref" do |node|
              if %w(public protected private).include? node.to_s
                @access_control = node.to_s
              end
            end

            # remember the current access control for methods.
            add_callback "start_vcall" do |node|
              if %w(public protected private).include? node.to_s
                @access_control = node.to_s
              end
            end

            # set access control to "public" by default.
            add_callback "start_class" do |node|
              @access_control = "public"
            end

            # set access control to "public" by default.
            add_callback "start_module" do |node|
              @access_control = "public"
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
