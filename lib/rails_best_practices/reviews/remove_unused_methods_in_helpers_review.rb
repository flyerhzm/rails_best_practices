# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    class RemoveUnusedMethodsInHelpersReview < Review
      # Find out unused methods in helpers.
      #
      # Implementation:
      #
      # Review process:
      #   remember all method calls in helpers.
      #   if they are not called in views or helpers,
      #   then they are unused methods in helpers.
      include Klassable
      include Completeable
      include Callable
      include Exceptable

      interesting_files HELPER_FILES, VIEW_FILES

      def initialize(options={})
        super
        @helper_methods = Prepares.helper_methods
      end

      # get all unused methods at the end of review process
      def on_complete
        @helper_methods.get_all_unused_methods.each do |method|
          if !excepted?(method)
            add_error "remove unused methods (#{method.class_name}##{method.method_name})", method.file, method.line
          end
        end
      end

      protected
        def methods
          @helper_methods
        end

        def internal_except_methods
          []
        end
    end
  end
end
