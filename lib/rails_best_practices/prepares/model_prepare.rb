# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remember models and model associations.
    class ModelPrepare < Core::Check
      include Core::Check::Classable

      ASSOCIATION_METHODS = %w(belongs_to has_one has_many has_and_belongs_to_many)

      def interesting_nodes
        [:class, :command, :module]
      end

      def interesting_files
        MODEL_FILES
      end

      def initialize
        @models = Prepares.models
        @model_associations = Prepares.model_associations
      end

      # check class node to remember the last class name.
      def start_class(node)
        @class_name= class_name(node)
        @models << @class_name
      end

      # check command node to remember all assoications.
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
        remember_association(node) if ASSOCIATION_METHODS.include? node.message.to_s
      end

      # remember associations, with class to association names.
      def remember_association(node)
        association_meta = node.message.to_s
        association_name = node.arguments.all[0].to_s
        arguments_node = node.arguments.all[1]
        if arguments_node && :bare_assoc_hash == arguments_node.sexp_type
          association_class = arguments_node.hash_value("class_name").to_s
        end
        association_class ||= association_name.classify
        @model_associations.add_association(@class_name, association_name, association_meta, association_class)
      end
    end
  end
end
