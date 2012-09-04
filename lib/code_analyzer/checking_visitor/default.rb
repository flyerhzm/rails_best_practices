# encoding: utf-8
module CodeAnalyzer::CheckingVisitor
  class Default
    def initialize(options={})
      @checks = {}
      @checkers = options[:checkers]
      @checkers.each do |checker|
        checker.interesting_nodes.each do |node|
          @checks[node] ||= []
          @checks[node] << checker
          @checks[node].uniq!
        end
      end
    end

    def check(filename, content)
      node = parse(filename, content)
      node.file = filename
      check_node(node)
    end

    def after_check
      @checkers.each do |checker|
        after_check_callbacks = checker.class.get_callbacks(:after_check)
        after_check_callbacks.each do |block|
          checker.instance_exec &block
        end
      end
    end

    # parse ruby code.
    #
    # @param [String] filename is the filename of ruby file.
    # @param [String] content is the source code of ruby file.
    def parse(filename, content)
      Sexp.from_array(Ripper::SexpBuilder.new(content).parse)
    rescue Exception
      raise AnalyzerException.new("#{filename} looks like it's not a valid Ruby file.  Skipping...")
    end

    def check_node(node)
      checkers = @checks[node.sexp_type]
      if checkers
        checkers.each { |checker|
          checker.node_start(node) if checker.parse_file?(node.file)
        }
      end
      node.children.each { |child_node|
        child_node.file = node.file
        child_node.check(self)
      }
      if checkers
        checkers.each { |checker|
          checker.node_end(node) if checker.parse_file?(node.file)
        }
      end
    end
  end
end
