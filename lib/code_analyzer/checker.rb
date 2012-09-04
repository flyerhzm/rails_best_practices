# encoding: utf-8
module CodeAnalyzer
  # A checker class that takes charge of checking the sexp.
  class Checker
    # interesting nodes that the check will parse.
    def interesting_nodes
      self.class.interesting_nodes
    end

    # interesting files that the check will parse.
    def interesting_files
      self.class.interesting_files
    end

    # check if the checker will parse the node file.
    #
    # @param [String] the file name of node.
    # @return [Boolean] true if the checker will parse the file.
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
      self.class.get_callbacks("start_#{node.sexp_type}").each do |block|
        self.instance_exec(node, &block)
      end
    end

    # delegate to end_### according to the sexp_type, like
    #
    #     end_call
    #     end_def
    #
    # @param [Sexp] node
    def node_end(node)
      @node = node
      self.class.get_callbacks("end_#{node.sexp_type}").each do |block|
        self.instance_exec(node, &block)
      end
    end

    # add an warning.
    #
    # @param [String] message, is the warning message
    # @param [String] filename, is the filename of source code
    # @param [Integer] line_number, is the line number of the source code which is reviewing
    def add_warning(message, filename = @node.file, line_number = @node.line)
      warnings << Warning.new(filename: filename, line_number: line_number, message: message)
    end

    def warnings
      @warnings ||= []
    end

    class <<self
      def interesting_nodes(*nodes)
        @interesting_nodes ||= []
        @interesting_nodes += nodes
      end

      def interesting_files(*file_patterns)
        @interesting_files ||= []
        @interesting_files += file_patterns
      end

      def get_callbacks(name)
        callbacks[name] ||= []
        callbacks[name]
      end

      def add_callback(*names, &block)
        names.each do |name|
          callbacks[name] ||= []
          callbacks[name] << block
        end
      end

      def callbacks
        @callbacks ||= {}
      end
    end
  end
end
