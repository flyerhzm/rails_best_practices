# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remember models and model associations.
    class ModelPrepare < Core::Check
      include Core::Check::Klassable
      include Core::Check::Accessable

      ASSOCIATION_METHODS = %w(belongs_to has_one has_many has_and_belongs_to_many)

      def interesting_nodes
        [:module, :class, :def, :command, :var_ref, :alias]
      end

      def interesting_files
        MODEL_FILES
      end

      def initialize
        @models = Prepares.models
        @model_associations = Prepares.model_associations
        @methods = Prepares.model_methods
      end

      # check class node to remember the last class name.
      def start_class(node)
        if "ActionMailer::Base" != current_extend_class_name
          @models << @klass
        end
      end

      # check ref node to remember all methods.
      #
      # the remembered methods (@methods) are like
      #     {
      #       "Post" => {
      #         "save" => {"file" => "app/models/post.rb", "line" => 10, "unused" => false, "unused" => false},
      #         "find" => {"file" => "app/models/post.rb", "line" => 10, "unused" => false, "unused" => false}
      #       },
      #       "Comment" => {
      #         "create" => {"file" => "app/models/comment.rb", "line" => 10, "unused" => false, "unused" => false},
      #       }
      #     }
      def start_def(node)
        if @klass && "ActionMailer::Base" != current_extend_class_name
          method_name = node.method_name.to_s
          @methods.add_method(current_class_name, method_name, {"file" => node.file, "line" => node.line}, current_access_control)
        end
      end

      # check command node to remember all assoications or named_scope/scope methods.
      #
      # the remembered association names (@associations) are like
      #     {
      #       "Project" => {
      #         "categories" => {"has_and_belongs_to_many" => "Category"},
      #         "project_manager" => {"has_one" => "ProjectManager"},
      #         "portfolio" => {"belongs_to" => "Portfolio"},
      #         "milestones => {"has_many" => "Milestone"}
      #       }
      #     }
      def start_command(node)
        case node.message.to_s
        when *%w(named_scope scope alias_method)
          method_name = node.arguments.all[0].to_s
          @methods.add_method(current_class_name, method_name, {"file" => node.file, "line" => node.line}, current_access_control)
        when "alias_method_chain"
          method, feature = *node.arguments.all.map(&:to_s)
          @methods.add_method(current_class_name, "#{method}_with_#{feature}", {"file" => node.file, "line" => node.line}, current_access_control)
          @methods.add_method(current_class_name, "#{method}", {"file" => node.file, "line" => node.line}, current_access_control)
        when *ASSOCIATION_METHODS
          remember_association(node)
        else
        end
      end

      # check alias node to remembr the alias methods.
      def start_alias(node)
        method_name = node.new_method.to_s
        @methods.add_method(current_class_name, method_name, {"file" => node.file, "line" => node.line}, current_access_control)
      end

      private
        # remember associations, with class to association names.
        def remember_association(node)
          association_meta = node.message.to_s
          association_name = node.arguments.all[0].to_s
          arguments_node = node.arguments.all[1]
          if arguments_node && :bare_assoc_hash == arguments_node.sexp_type
            association_class = arguments_node.hash_value("class_name").to_s
          end
          association_class ||= association_name.classify
          @model_associations.add_association(current_class_name, association_name, association_meta, association_class)
        end
    end
  end
end
