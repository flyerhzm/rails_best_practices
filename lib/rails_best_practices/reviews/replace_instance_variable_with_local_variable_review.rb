# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review a partail view file to make sure there is no instance variable.
    #
    # See the best practice details here
    # http://rails-bestpractices.com/posts/27-replace-instance-variable-with-local-variable.
    #
    # Implementation:
    #
    # Review process:
    #   check all instance variable in partial view files,
    #   if exist, then they should be replaced with local variable
    class ReplaceInstanceVariableWithLocalVariableReview < Review
      interesting_nodes :var_ref, :vcall
      interesting_files PARTIAL_VIEW_FILES

      def url
        "http://rails-bestpractices.com/posts/27-replace-instance-variable-with-local-variable"
      end

      # check ivar node in partial view file,
      # it is an instance variable, and should be replaced with local variable.
      def start_var_ref(node)
        if node.to_s.start_with?('@')
          add_error "replace instance variable with local variable"
        end
      end

      # check ivar node in partial view file,
      # it is an instance variable, and should be replaced with local variable.
      def start_vcall(node)
        if node.to_s.start_with?('@')
          add_error "replace instance variable with local variable"
        end
      end
    end
  end
end
