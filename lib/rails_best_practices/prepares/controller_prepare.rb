# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remember controllers and controller methods
    class ControllerPrepare < Core::Check
      def interesting_nodes
        [:class, :def]
      end

      def interesting_files
        CONTROLLER_FILES
      end

      def initialize
        @methods = Prepares.controller_methods
      end

      # check class node to remember the last class name.
      def start_class(node)
        @last_klazz = node.class_name.to_s
      end

      # check def node to remember all methods.
      #
      # the remembered methods (@methods) are like
      #     {
      #       "Post" => ["create", "destroy"],
      #       "Comment" => ["create"]
      #     }
      def start_def(node)
        method_name = node.method_name.to_s
        @methods.add_method(@last_klazz, method_name)
      end
    end
  end
end
