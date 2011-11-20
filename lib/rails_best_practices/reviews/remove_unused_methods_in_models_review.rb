# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Find out unused methods in models.
    #
    # Implemenation:
    #
    # Review process:
    #   remember all method calls,
    #   at end, check if all defined methods are called,
    #   if not, non called methods are unused.
    class RemoveUnusedMethodsInModelsReview < Review
      include Klassable
      include Completeable
      include Callable

      interesting_files ALL_FILES

      EXCEPT_METHODS = %w(initialize validate to_xml to_json assign_attributes after_find after_initialize)

      def initialize(options={})
        super()
        @model_methods = Prepares.model_methods
        @except_methods = EXCEPT_METHODS + options['except_methods']
      end

      # get all unused methods at the end of review process.
      def on_complete
        @model_methods.get_all_unused_methods.each do |method|
          if !@except_methods.include?(method.method_name) && method.method_name !~ /=$/
            add_error "remove unused methods (#{method.class_name}##{method.method_name})", method.file, method.line
          end
        end
      end

      protected
        def methods
          @model_methods
        end
    end
  end
end
