# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a view file to make sure there is no complex logic call for model.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/25-move-code-into-model.
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   check if a local variable or instance variable called more than call count defined in conditional statement nodes,
    #   then it should be moved into model.
    class MoveCodeIntoModelCheck < Check

      def interesting_review_nodes
        [:if]
      end

      def interesting_review_files
        VIEW_FILES
      end

      def initialize(options={})
        super()
        @call_count = options['call_count'] || 2
      end

      # check if node to see whose conditional statementnodes contain multiple call nodes with same subject who is a local variable or instance variable.
      #
      # it will check every call nodes in the conditional statement nodes.
      #
      # if there are more than @call_count call nodes who has the same subject,
      # and the subject is a local variable or an instance variable,
      # then the conditional statement nodes should be moved into model.
      def review_start_if(node)
        @variable_call_count = {}
        node.conditional_statement.grep_nodes(:node_type => :call).each { |call_node| remember_variable_call_count(call_node) }

        @variable_call_count.each do |variable_node, count|
          add_error "move code into model (#{variable_node})", variable_node.file, variable_node.line if count > @call_count
        end
      end

      private
        # remember call count for the local or instance variable in the call node.
        #
        # find the local variable or instance variable in the call node,
        # then save it to as key in @variable_call_count hash, and add the call count (hash value).
        def remember_variable_call_count(call_node)
          variable_node = variable(call_node)
          if variable_node
            @variable_call_count[variable_node] ||= 0
            @variable_call_count[variable_node] += 1
          end
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
        def variable(call_node)
          while call_node.subject.node_type == :call
            call_node = call_node.subject
          end
          subject_node = call_node.subject
          if [:ivar, :lvar].include?(subject_node.node_type) and subject_node[1] != :_erbout
            subject_node
          else
            nil
          end
        end
    end
  end
end
