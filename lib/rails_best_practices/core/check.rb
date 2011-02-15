# encoding: utf-8
module RailsBestPractices
  module Core
    # A Check class that takes charge of checking the sexp.
    class Check
      # only nodes whose node_type is in NODE_TYPE will be reviewed.
      NODE_TYPES = [:call, :defn, :defs, :if, :class, :lasgn, :iasgn, :ivar, :lvar, :block, :iter, :const]

      CONTROLLER_FILES = /_controller\.rb$/
      MIGRATION_FILES = /db\/migrate\/.*\.rb$/
      MODEL_FILES = /models\/.*\.rb$/
      MAILER_FILES = /models\/.*\.rb$|mailers\/.*\.rb/
      VIEW_FILES = /views\/.*\.(erb|haml)$/
      PARTIAL_VIEW_FILES = /views\/.*\/_.*\.(erb|haml)$/
      ROUTE_FILE = /config\/routes.rb/

      attr_reader :errors

      def initialize
        @errors = []
      end

      # default interesting nodes.
      def interesting_nodes
        []
      end

      # default interesting files.
      def interesting_files
        /.*/
      end

      # delegate to start_### according to the node_type, like
      #
      #     start_call
      #     start_defn
      #
      # @param [Sexp] node
      def node_start(node)
        @node = node
        self.send("start_#{node.node_type}", node)
      end

      # delegate to end_### according to the node_type, like
      #
      #     end_call
      #     end_defn
      #
      # @param [Sexp] node
      def node_end(node)
        @node = node
        self.send("end_#{node.node_type}", node)
      end

      # add error if source code violates rails best practice.
      #   error is the string message for violation of the rails best practice
      #   file is the filename of source code
      #   line is the line number of the source code which is reviewing
      def add_error(error, file = @node.file, line = @node.line)
        @errors << RailsBestPractices::Core::Error.new("#{file}", "#{line}", error, url)
      end

      # default url is empty.
      #
      # @return [String] the url of rails best practice
      def url
        ""
      end

      # method_missing to catch all start and end process for each node type, like
      #
      #     start_defn
      #     end_defn
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
    end
  end
end
