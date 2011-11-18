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
      #     {:lexicals => [], :prepares => [], :reviews => []}
      def initialize(options={})
        @lexicals = options[:lexicals]
        [:prepare, :review].each do |process|
          instance_variable_set("@#{process}_checks", {})                  # @review_checks = {}
          options["#{process}s".to_sym].each do |check|                    # options[:reviews].each do |check|
            check.send("interesting_nodes").each do |node|                 #   check.interesting_nodes.each do |node|
              instance_variable_get("@#{process}_checks")[node] ||= []     #     @review_checks[node] ||= []
              instance_variable_get("@#{process}_checks")[node] << check   #     @review_checks[node] << check
              instance_variable_get("@#{process}_checks")[node].uniq!      #     @review_checks[node].uniq!
            end                                                            #   end
          end                                                              # end
        end
      end

      # for lexical process
      # check the content of files one by one.
      def lexical(filename, content)
        @lexicals.each do |lexical|
          lexical.check(filename, content)
        end
      end

      # for prepare process
      # if the sexp_type and the node filename match the interesting_nodes and interesting_files,
      # then run the prepare for that node.
      #
      # for review process
      # if the sexp_type and the node filename match the interesting_nodes and interesting_files,
      # then run the reivew for that node.
      [:prepare, :review].each do |process|
        class_eval <<-EOS
          def #{process}(node)                                         # def review(node)
            checks = @#{process}_checks[node.sexp_type]                #   checks = @review_checks[node.sexp_type]
            if checks                                                  #   if checks
              checks.each { |check|                                    #     checks.each { |check|
                if check.parse_file?(node.file)                        #      if check.parse_file?(node.file)
                  check.node_start(node)                               #         check.node_start(node)
                end                                                    #       end
              }                                                        #     }
            end                                                        #   end
            node.children.each { |sexp|                                #   node.children.each { |sexp|
              sexp.file = node.file                                    #     sexp.filename = node.file
              sexp.#{process}(self)                                    #     sexp.review(self)
            }                                                          #   }
            if checks                                                  #   if checks
              checks.each { |check|                                    #     checks.each { |check|
                if check.parse_file?(node.file)                        #      if check.parse_file?(node.file)
                  check.node_end(node)                                 #         check.node_end(node)
                end                                                    #       end
              }                                                        #     }
            end                                                        #   end
          end                                                          # end
        EOS
      end
    end
  end
end
