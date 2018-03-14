# encoding: utf-8
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
      add_callback :start_module do |node|
        @helpers << Core::Mod.new(current_module_name, [])
      end

      # check def node to remember all methods.
      #
      # the remembered methods (@methods) are like
      #     {
      #       "PostsHelper" => {
      #         "create_time" => {"file" => "app/helpers/posts_helper.rb", "line_number" => 10, "unused" => false},
      #         "update_time" => {"file" => "app/helpers/posts_helper.rb", "line_number" => 10, "unused" => false}
      #       }
      #     }
      add_callback :start_def do |node|
        if node.file =~ HELPER_FILES
          method_name = node.method_name.to_s
          @methods.add_method(current_module_name, method_name, { 'file' => node.file, 'line_number' => node.line_number }, current_access_control)
        end
      end
    end
  end
end
