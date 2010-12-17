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
      MODEL_FILES = /models\/.*\.rb$/
      MAILER_FILES = /models\/.*\.rb$|mailers\/.*\.rb/
      VIEW_FILES = /views\/.*\.(erb|haml)$/
      PARTIAL_VIEW_FILES = /views\/.*\/_.*\.(erb|haml)$/
      ROUTE_FILE = /config\/routes.rb/

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

      def self.prepare_model_associations
        class_eval <<-EOS
          def initialize
            super
            @klazzes = []
            @associations = {}
          end

          def interesting_prepare_nodes
            [:class, :call]
          end

          def interesting_prepare_files
            MODEL_FILES
          end

          # check class node to remember all class name in prepare process.
          #
          # the remembered class names (@klazzes) are like
          #     [ :User, :Post ]
          def prepare_start_class(node)
            remember_klazz(node)
          end

          # check call node to remember all assoication names in prepare process.
          #
          # the remembered association names (@associations) are like
          #     { :User => [":projects", ":location"], :Post => [":comments"] }
          def prepare_start_call(node)
            remember_association(node) if association_methods.include? node.message
          end

          # remember class models, just the subject of class node.
          def remember_klazz(class_node)
            @klazzes << class_node.class_name
          end

          # remember associations, with class to association names.
          def remember_association(association_node)
            @associations[@klazzes.last] ||= []
            @associations[@klazzes.last] << association_node.arguments[1].to_s
          end

          def association_methods
            [:belongs_to, :has_one, :has_many, :has_and_belongs_to_many]
          end

        EOS
      end

      # add error if source code violates rails best practice.
      #   error is the string message for violation of the rails best practice
      #   file is the filename of source code
      #   line is the line number of the source code which is reviewing
      def add_error(error, file = @node.file, line = @node.line)
        @errors << RailsBestPractices::Core::Error.new("#{file}", "#{line}", error)
      end

      # remember use count for the local or instance variable in the call or attrasgn node.
      #
      # find the local variable or instance variable in the call or attrasgn node,
      # then save it to as key in @variable_use_count hash, and add the call count (hash value).
      def remember_variable_use_count(node)
        variable_node = variable(node)
        if variable_node
          variable_use_count[variable_node] ||= 0
          variable_use_count[variable_node] += 1
        end
      end

      # return @variable_use_count hash.
      def variable_use_count
        @variable_use_count ||= {}
      end

      # reset @variable_use_count hash.
      def reset_variable_use_count
        @variable_use_count = nil
      end

      # find local variable or instance variable in the most inner call node, e.g.
      #
      # if the call node is
      #
      #     s(:call, s(:ivar, :@post), :editors, s(:arglist)),
      #
      # or it is
      #
      #     s(:call,
      #       s(:call, s(:ivar, :@post), :editors, s(:arglist)),
      #       :include?,
      #       s(:arglist, s(:call, nil, :current_user, s(:arglist)))
      #     )
      #
      # then the variable both are s(:ivar, :@post).
      #
      def variable(node)
        while node.subject.node_type == :call
          node = node.subject
        end
        subject_node = node.subject
        if [:ivar, :lvar].include?(subject_node.node_type) and subject_node[1] != :_erbout
          subject_node
        else
          nil
        end
      end

      # compare two sexp nodes' to_s.
      #     equal?(":test", :test) => true
      #     equai?("@test", :test) => true
      def equal?(node, expected_node)
        actual = node.to_s.downcase
        expected = expected_node.to_s.downcase
        actual == expected || actual == ':' + expected || actual == '@' + expected
      end
    end
  end
end
