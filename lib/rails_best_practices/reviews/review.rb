# encoding: utf-8
require 'rails_best_practices/core/check'
require 'rails_best_practices/core/error'

module RailsBestPractices
  module Reviews
    # A Review class that takes charge of reviewing one rails best practice.
    class Review < Core::Check
      attr_reader :errors

      def initialize
        super
        @errors = []
      end

      # add error if source code violates rails best practice.
      #   error is the string message for violation of the rails best practice
      #   file is the filename of source code
      #   line is the line number of the source code which is reviewing
      def add_error(error, file = @node.file, line = @node.line)
        @errors << RailsBestPractices::Core::Error.new("#{file}", "#{line}", error, url)
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

      # get the model associations from Prepares.
      #
      # @return [Hash]
      def model_associations
        @model_associations ||= Prepares.model_associations
      end

      # compare two sexp nodes' to_s.
      #
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
