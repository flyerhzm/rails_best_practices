# encoding: utf-8
module CodeAnalyzer::CheckingVisitor
  class Default
    def initialize(options={})
      @checks = {}
      options[:checkers].each do |checker|
        checker.interesting_nodes.each do |node|
          @checks[node] ||= []
          @checks[node] << checker
        end
      end
    end

    def check(filename, content)
      node = parse(filename, content)
      node.file = filename
      check_node(node)
    end

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
      node.children.each { |sexp|
        sexp.file = node.file
        sexp.check(self)
      }
      if checkers
        checkers.each { |checker|
          checker.node_end(node) if checker.parse_file?(node.file)
        }
      end
    end
  end
end
