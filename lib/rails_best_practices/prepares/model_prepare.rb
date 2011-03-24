# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remember the model associations.
    class ModelPrepare < Core::Check

      def interesting_nodes
        [:class, :call]
      end

      def interesting_files
        MODEL_FILES
      end

      def initialize
        @models = Core::Models.new
        @model_associations = Core::ModelAssociations.new
      end

      # check class node to remember the last class name.
      def start_class(class_node)
        @last_klazz = class_node.class_name.to_s
        @models << @last_klazz
      end

      # assign @model_associations to Prepares.model_associations.
      def end_class(class_node)
        Prepares.models = @models
        Prepares.model_associations = @model_associations
      end

      # check call node to remember all assoications.
      #
      # the remembered association names (@associations) are like
      #     {
      #       :Project=>{
      #         "categories" => {:has_and_belongs_to_many => "Category"},
      #         "project_manager" => {:has_one => "ProjectManager"},
      #         "portfolio" => {:belongs_to => "Portfolio"},
      #         "milestones => {:has_many" => "Milestone"}
      #       }
      #     }
      def start_call(node)
        remember_association(node) if association_methods.include? node.message
      end

      # remember associations, with class to association names.
      def remember_association(association_node)
        association_meta = association_node.message
        association_name = association_node.arguments[1].to_s
        arguments_node = association_node.arguments[2]
        if arguments_node && :hash == arguments_node.node_type
          index = arguments_node.index(s(:lit, :class_name))
          association_class = arguments_node[index + 1].to_s if index
        end
        @model_associations.add_association(@last_klazz, association_name, association_meta, association_class)
      end

      # default rails association methods.
      def association_methods
        [:belongs_to, :has_one, :has_many, :has_and_belongs_to_many]
      end
    end
  end
end
