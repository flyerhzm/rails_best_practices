# encoding: utf-8
# frozen_string_literal: true

module RailsBestPractices
  module Prepares
    # Remember models and model associations.
    class ModelPrepare < Core::Check
      include Core::Check::Classable
      include Core::Check::Accessable

      interesting_nodes :class, :def, :defs, :command, :alias
      interesting_files MODEL_FILES

      ASSOCIATION_METHODS = %w(belongs_to has_one has_many has_and_belongs_to_many embeds_many embeds_one embedded_in many one)

      def initialize
        @models = Prepares.models
        @model_associations = Prepares.model_associations
        @model_attributes = Prepares.model_attributes
        @methods = Prepares.model_methods
      end

      # remember the class name.
      add_callback :start_class do |node|
        if 'ActionMailer::Base' != current_extend_class_name
          @models << @klass
        end
      end

      # check def node to remember all methods.
      #
      # the remembered methods (@methods) are like
      #     {
      #       "Post" => {
      #         "save" => {"file" => "app/models/post.rb", "line_number" => 10, "unused" => false, "unused" => false},
      #         "find" => {"file" => "app/models/post.rb", "line_number" => 10, "unused" => false, "unused" => false}
      #       },
      #       "Comment" => {
      #         "create" => {"file" => "app/models/comment.rb", "line_number" => 10, "unused" => false, "unused" => false},
      #       }
      #     }
      add_callback :start_def do |node|
        if @klass &&
            'ActionMailer::Base' != current_extend_class_name &&
            (classable_modules.empty? || klasses.any?)
          method_name = node.method_name.to_s
          @methods.add_method(current_class_name, method_name, {'file' => node.file, 'line_number' => node.line_number}, current_access_control)
        end
      end

      # check defs node to remember all static methods.
      #
      # the remembered methods (@methods) are like
      #     {
      #       "Post" => {
      #         "save" => {"file" => "app/models/post.rb", "line_number" => 10, "unused" => false, "unused" => false},
      #         "find" => {"file" => "app/models/post.rb", "line_number" => 10, "unused" => false, "unused" => false}
      #       },
      #       "Comment" => {
      #         "create" => {"file" => "app/models/comment.rb", "line_number" => 10, "unused" => false, "unused" => false},
      #       }
      #     }
      add_callback :start_defs do |node|
        if @klass && 'ActionMailer::Base' != current_extend_class_name
          method_name = node.method_name.to_s
          @methods.add_method(current_class_name, method_name, {'file' => node.file, 'line_number' => node.line_number}, current_access_control)
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
      add_callback :start_command do |node|
        case node.message.to_s
        when *%w(named_scope scope alias_method)
          method_name = node.arguments.all.first.to_s
          @methods.add_method(current_class_name, method_name, {'file' => node.file, 'line_number' => node.line_number}, current_access_control)
        when 'alias_method_chain'
          method, feature = *node.arguments.all.map(&:to_s)
          @methods.add_method(current_class_name, "#{method}_with_#{feature}", {'file' => node.file, 'line_number' => node.line_number}, current_access_control)
          @methods.add_method(current_class_name, "#{method}", {'file' => node.file, 'line_number' => node.line_number}, current_access_control)
        when 'field'
          arguments = node.arguments.all
          attribute_name = arguments.first.to_s
          attribute_type = arguments.last.hash_value('type').present? ? arguments.last.hash_value('type').to_s : 'String'
          @model_attributes.add_attribute(current_class_name, attribute_name, attribute_type)
        when 'key'
          attribute_name, attribute_type = node.arguments.all.map(&:to_s)
          @model_attributes.add_attribute(current_class_name, attribute_name, attribute_type)
        when *ASSOCIATION_METHODS
          remember_association(node)
        else
        end
      end

      # check alias node to remembr the alias methods.
      add_callback :start_alias do |node|
        method_name = node.new_method.to_s
        @methods.add_method(current_class_name, method_name, {'file' => node.file, 'line_number' => node.line_number}, current_access_control)
      end

      # after prepare process, fix incorrect associations' class_name.
      add_callback :after_check do
        @model_associations.each do |model, model_associations|
          model_associations.each do |association_name, association_meta|
            unless @models.include?(association_meta['class_name'])
              if @models.include?("#{model}::#{association_meta['class_name']}")
                association_meta['class_name'] = "#{model}::#{association_meta['class_name']}"
              elsif @models.include?(model.gsub(/::\w+$/, ''))
                association_meta['class_name'] = model.gsub(/::\w+$/, '')
              end
            end
          end
        end
      end

      private

        # remember associations, with class to association names.
        def remember_association(node)
          association_meta = node.message.to_s
          association_name = node.arguments.all.first.to_s
          arguments_node = node.arguments.all.last
          if arguments_node.hash_value('class_name').present?
            association_class = arguments_node.hash_value('class_name').to_s
          end
          association_class ||= association_name.classify
          @model_associations.add_association(current_class_name, association_name, association_meta, association_class)
        end
    end
  end
end
