# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remember controllers and controller methods
    class ControllerPrepare < Core::Check
      include Core::Check::Klassable
      include Core::Check::InheritedResourcesable
      include Core::Check::Accessable

      interesting_nodes :class, :var_ref, :command, :def
      interesting_files CONTROLLER_FILES

      DEFAULT_ACTIONS = %w(index show new create edit update destroy)

      def initialize
        @controllers = Prepares.controllers
        @methods = Prepares.controller_methods
        @inherited_resources = false
      end

      # check class node to remember the class name.
      # also check if the controller is inherit from InheritedResources::Base.
      def start_class(node)
        @controllers << @klass
        if @inherited_resources
          @actions = DEFAULT_ACTIONS
        end
      end

      # remember the action names at the end of class node if the controller is a InheritedResources.
      def end_class(node)
        if @inherited_resources && "ApplicationController" != current_class_name
          @actions.each do |action|
            @methods.add_method(current_class_name, action, {"file" => node.file, "line" => node.line})
          end
        end
      end

      # check if there is a DSL call inherit_resources.
      def start_var_ref(node)
        if @inherited_resources
          @actions = DEFAULT_ACTIONS
        end
      end

      # restrict actions for inherited_resources
      def start_command(node)
        if @inherited_resources && "actions" ==  node.message.to_s
          if "all" == node.arguments.all.first.to_s
            @actions = DEFAULT_ACTIONS
            option_argument = node.arguments.all[1]
            if :bare_assoc_hash == option_argument.sexp_type && option_argument.hash_value("except")
              @actions -= option_argument.hash_value("except").to_object
            end
          else
            @actions = node.arguments.all.map(&:to_s)
          end
        end
      end

      # check def node to remember all methods.
      #
      # the remembered methods (@methods) are like
      #     {
      #       "PostsController" => {
      #         "save" => {"file" => "app/controllers/posts_controller.rb", "line" => 10, "unused" => false},
      #         "find" => {"file" => "app/controllers/posts_controller.rb", "line" => 10, "unused" => false}
      #       },
      #       "CommentsController" => {
      #         "create" => {"file" => "app/controllers/comments_controller.rb", "line" => 10, "unused" => false},
      #       }
      #     }
      def start_def(node)
        method_name = node.method_name.to_s
        @methods.add_method(current_class_name, method_name, {"file" => node.file, "line" => node.line}, current_access_control)
      end
    end
  end
end
