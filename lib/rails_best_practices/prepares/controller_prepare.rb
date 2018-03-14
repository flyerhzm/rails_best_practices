# encoding: utf-8
# frozen_string_literal: true

module RailsBestPractices
  module Prepares
    # Remember controllers and controller methods
    class ControllerPrepare < Core::Check
      include Core::Check::Classable
      include Core::Check::InheritedResourcesable
      include Core::Check::Accessable

      interesting_nodes :class, :var_ref, :vcall, :command, :def
      interesting_files CONTROLLER_FILES

      DEFAULT_ACTIONS = %w(index show new create edit update destroy)

      def initialize
        @controllers = Prepares.controllers
        @methods = Prepares.controller_methods
        @helpers = Prepares.helpers
        @inherited_resources = false
      end

      # check class node to remember the class name.
      # also check if the controller is inherit from InheritedResources::Base.
      add_callback :start_class do |node|
        @controllers << @klass
        if @inherited_resources
          @actions = DEFAULT_ACTIONS
        end
      end

      # remember the action names at the end of class node if the controller is a InheritedResources.
      add_callback :end_class do |node|
        if @inherited_resources && 'ApplicationController' != current_class_name
          @actions.each do |action|
            @methods.add_method(current_class_name, action, { 'file' => node.file, 'line_number' => node.line_number })
          end
        end
      end

      # check if there is a DSL call inherit_resources.
      add_callback :start_var_ref do |node|
        if @inherited_resources
          @actions = DEFAULT_ACTIONS
        end
      end

      # check if there is a DSL call inherit_resources.
      add_callback :start_vcall do |node|
        if @inherited_resources
          @actions = DEFAULT_ACTIONS
        end
      end

      # restrict actions for inherited_resources
      add_callback :start_command do |node|
        if 'include' == node.message.to_s
          @helpers.add_module_descendant(node.arguments.all.first.to_s, current_class_name)
        elsif @inherited_resources && 'actions' ==  node.message.to_s
          if 'all' == node.arguments.all.first.to_s
            @actions = DEFAULT_ACTIONS
            option_argument = node.arguments.all[1]
            if option_argument && :bare_assoc_hash == option_argument.sexp_type && option_argument.hash_value('except')
              @actions -= option_argument.hash_value('except').to_object
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
      #         "save" => {"file" => "app/controllers/posts_controller.rb", "line_number" => 10, "unused" => false},
      #         "find" => {"file" => "app/controllers/posts_controller.rb", "line_number" => 10, "unused" => false}
      #       },
      #       "CommentsController" => {
      #         "create" => {"file" => "app/controllers/comments_controller.rb", "line_number" => 10, "unused" => false},
      #       }
      #     }
      add_callback :start_def do |node|
        method_name = node.method_name.to_s
        @methods.add_method(current_class_name, method_name, { 'file' => node.file, 'line_number' => node.line_number }, current_access_control)
      end

      # ask Reviews::RemoveUnusedMoethodsInHelperReview to check the controllers who include helpers.
      add_callback :after_check do
        descendants = @helpers.map(&:descendants).flatten
        if descendants.present?
          Reviews::RemoveUnusedMethodsInHelpersReview.interesting_files *descendants.map { |descendant| %r|#{descendant.underscore}| }
        end
      end
    end
  end
end
