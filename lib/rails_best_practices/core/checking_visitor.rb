# encoding: utf-8
module RailsBestPractices
  module Core
    # CheckingVisitor is a visitor class.
    #
    # it remembers all the checks for prepare and review processes according to interesting_nodes and interesting_nodes,
    # then recursively iterate all sexp nodes,
    #
    # for prepare process
    # if the sexp_type and the node filename match the interesting_prepare_nodes and interesting_files,
    # then run the prepare for that node.
    #
    # for review process
    # if the sexp_type and the node filename match the interesting_review_nodes and interesting_files,
    # then run the reivew for that node.
    class CheckingVisitor
      # remember all the checks for prepare and review processes according to interesting_nodes.
      #
      # @param [Hash] options
      #     {lexicals: [], prepares: [], reviews: []}
      def initialize(options={})
        @checks = {}
        if options[:checkers]
          options[:checkers].each do |check|
            check.interesting_nodes.each do |node|
              @checks[node] ||= []
              @checks[node] << check
            end
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

    class LexicalCheckingVisitor
      def initialize(options={})
        @checkers = options[:checkers]
      end

      def check(filename, content)
        @checkers.each do |checker|
          checker.check(filename, content)
        end
      end
    end
  end
end
