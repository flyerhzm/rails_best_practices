# encoding: utf-8
module CodeAnalyzer::CheckingVisitor
  class Default
    def initialize(options={})
      @checks = {}
      options[:checkers].each do |check|
        check.interesting_nodes.each do |node|
          @checks[node] ||= []
          @checks[node] << check
        end
      end
    end

    def check(node)
      checks = @checks[node.sexp_type]
      if checks
        checks.each { |check|
          if check.parse_file?(node.file)
            check.node_start(node)
          end
        }
      end
      node.children.each { |sexp|
        sexp.file = node.file
        sexp.check(self)
      }
      if checks
        checks.each { |check|
          if check.parse_file?(node.file)
            check.node_end(node)
          end
        }
      end
    rescue Exception
      puts "find error in file: \#{node.file} line: \#{node.line}"
      raise $!
    end
  end
end
