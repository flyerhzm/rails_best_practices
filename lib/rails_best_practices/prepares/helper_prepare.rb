# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remember helper methods.
    class HelperPrepare < Core::Check
      include Core::Check::Moduleable
      include Core::Check::Accessable

      interesting_nodes :def, :command
      interesting_files HELPER_FILES, CONTROLLER_FILES

      def initialize
        @helpers = Prepares.helpers
        @methods = Prepares.helper_methods
      end

      # check module node to remember the module name.
      def start_module(node)
        @helpers << Core::Mod.new(current_module_name, [])
      end

      # check def node to remember all methods.
      #
      # the remembered methods (@methods) are like
      #     {
      #       "PostsHelper" => {
      #         "create_time" => {"file" => "app/helpers/posts_helper.rb", "line" => 10, "unused" => false},
      #         "update_time" => {"file" => "app/helpers/posts_helper.rb", "line" => 10, "unused" => false}
      #       }
      #     }
      def start_def(node)
        if node.file =~ HELPER_FILES
          method_name = node.method_name.to_s
          @methods.add_method(current_module_name, method_name, {"file" => node.file, "line" => node.line}, current_access_control)
        end
      end
    end
  end
end
