# encoding: utf-8
module RailsBestPractices
  module Reviews
    # Find out unused methods in helpers.
    #
    # Implementation:
    #
    # Review process:
    #   remember all method calls in helpers.
    #   if they are not called in views or helpers,
    #   then they are unused methods in helpers.
    class RemoveUnusedMethodsInHelpersReview < Review
      include Moduleable
      include Callable
      include Exceptable

      interesting_files HELPER_FILES, VIEW_FILES

      def initialize(options={})
        super
        @helper_methods = Prepares.helper_methods
        self.class.interesting_files Prepares.helpers.map(&:decendants)
      end

      # get all unused methods at the end of review process
      add_callback :after_check do
        @helper_methods.get_all_unused_methods.each do |method|
          if !excepted?(method)
            add_error "remove unused methods (#{method.class_name}##{method.method_name})", method.file, method.line_number
          end
        end
      end

      protected
        def methods
          @helper_methods
        end

        def internal_except_methods
          ["*#url_for"]
        end
    end
  end
end
