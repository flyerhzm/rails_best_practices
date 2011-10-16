# encoding: utf-8
module RailsBestPractices
  module Core
    # A Check class that takes charge of checking the sexp.
    class Check

      CONTROLLER_FILES = /controllers\/.*\.rb$/
      MIGRATION_FILES = /db\/migrate\/.*\.rb$/
      MODEL_FILES = /models\/.*\.rb$/
      MAILER_FILES = /models\/.*mailer\.rb$|mailers\/.*mailer\.rb/
      VIEW_FILES = /views\/.*\.(erb|haml)$/
      PARTIAL_VIEW_FILES = /views\/.*\/_.*\.(erb|haml)$/
      ROUTE_FILES = /config\/routes(.*)?\.rb/
      SCHEMA_FILE = /db\/schema\.rb/
      HELPER_FILES = /helpers.*\.rb$/

      # default interesting nodes.
      def interesting_nodes
        []
      end

      # default interesting files.
      def interesting_files
        /.*/
      end

      # delegate to start_### according to the sexp_type, like
      #
      #     start_call
      #     start_def
      #
      # @param [Sexp] node
      def node_start(node)
        @node = node
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

      # add error if source code violates rails best practice.
      #
      # @param [String] error, is the string message for violation of the rails best practice
      # @param [String] file, is the filename of source code
      # @param [Integer] line, is the line number of the source code which is reviewing
      def add_error(error, file = @node.file, line = @node.line)
        errors << RailsBestPractices::Core::Error.new("#{file}", "#{line}", error, url)
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
      end

      # Helper to parse the class name.
      module Klassable
        def self.included(base)
          base.class_eval do
            # remember module name
            add_callback "start_module" do |node|
              modules << node.module_name.to_s
            end

            # end of the module.
            add_callback "end_module" do |node|
              modules.pop
            end

            # remember the class anem
            add_callback "start_class" do |node|
              @klass = Core::Klass.new(node.class_name.to_s, node.base_class.to_s, modules)
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
        def modules
          @moduels ||= []
        end
      end

      # Helper to add callback after all files reviewed.
      module Completeable
        def self.included(base)
          base.class_eval do
            add_callback "end_class" do |node|
              if "RailsBestPractices::Complete" == node.class_name.to_s
                on_complete
              end
            end
          end
        end
      end

      # Helper to parse the access control.
      module Accessable
        def self.included(base)
          base.class_eval do
            # remember the current access control for methods.
            add_callback "start_var_ref" do |node|
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
