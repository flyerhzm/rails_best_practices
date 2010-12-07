# encoding: utf-8
require 'rails_best_practices/core/error'

module RailsBestPractices
  module Checks
    # A Check class that takes charge of reviewing one rails best practice.
    # One check contains two process:
    # 1. prepare process (optional), in this process, one check will do some preparation, such as analyzing the model associations.The check only does the preparation for the nodes (defined in interesting_prepare_nodes) in the files (defined in interesting_prepare_files).
    # 2. review process, in this process, one check will really review your rails codes. The check only review the nodes (defined in interesting_review_nodes) in the files # (defined in interesting_review_files).
    class Check
      # only nodes whose node_type is in NODE_TYPE will be reviewed.
      NODE_TYPES = [:call, :defn, :defs, :if, :class, :lasgn, :iasgn, :ivar, :lvar, :block, :iter, :const]

      CONTROLLER_FILES = /_controller\.rb$/
      MIGRATION_FILES = /db\/migrate\/.*\.rb$/
      MODLE_FILES = /models\/.*\.rb$/
      VIEW_FILES = /views\/.*\.(erb|haml)$/
      PARTIAL_VIEW_FILES = /views\/.*\/_.*\.(erb|haml)$/

      attr_reader :errors

      def initialize
        @errors = []
      end

      [:prepare, :review].each do |process|
        class_eval <<-EOS
          def interesting_#{process}_nodes                        # def interesting_review_nodes
            []                                                    #   []
          end                                                     # end
                                                                  #
          def interesting_#{process}_files                        # def interesting_review_files
            /.*/                                                  #   /.*/
          end                                                     # end
                                                                  #
          def #{process}_node_start(node)                         # def review_node_start(node)
            @node = node                                          #   @node = node
            method = "#{process}_start_" + node.node_type.to_s    #   method = "review_start_" + node.node_type.to_s
            self.send(method, node)                               #   self.send(method, node)
          end                                                     # end
                                                                  #
          def #{process}_node_end(node)                           # def review_node_end(node)
            @node = node                                          #   @node = node
            method = "#{process}_end_" + node.node_type.to_s      #   method = "review_end_" + node.node_type.to_s
            self.send(method, node)                               #   self.send(method, node)
          end                                                     # end
        EOS
      end

      [:prepare, :review].each do |process|
        NODE_TYPES.each do |node|
          class_eval <<-EOS
            def #{process}_start_#{node}(node)                    # def review_start_def(node)
            end                                                   # end
                                                                  #
            def #{process}_end_#{node}(node)                      # def review_end_def(node)
            end                                                   # end
          EOS
        end
      end

      # add error if source code violates rails best practice.
      #   error is the string message for violation of the rails best practice
      #   file is the filename of source code
      #   line is the line number of the source code which is reviewing
      def add_error(error, file = @node.file, line = @node.line)
        @errors << RailsBestPractices::Core::Error.new("#{file}", "#{line}", error)
      end

      # compare two sexp nodes' to_s.
      #     equal?(":test", :test) => true
      def equal?(node, expected)
        node.to_s == expected or node.to_s == ':' + expected.to_s
      end
    end
  end
end
