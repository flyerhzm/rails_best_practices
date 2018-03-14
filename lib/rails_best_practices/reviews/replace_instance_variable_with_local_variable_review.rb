# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review a partail view file to make sure there is no instance variable.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/07/24/replace-instance-variable-with-local-variable/
    #
    # Implementation:
    #
    # Review process:
    #   check all instance variable in partial view files,
    #   if exist, then they should be replaced with local variable
    class ReplaceInstanceVariableWithLocalVariableReview < Review
      interesting_nodes :var_ref, :vcall
      interesting_files PARTIAL_VIEW_FILES
      url 'https://rails-bestpractices.com/posts/2010/07/24/replace-instance-variable-with-local-variable/'

      # check ivar node in partial view file,
      # it is an instance variable, and should be replaced with local variable.
      add_callback :start_var_ref, :start_vcall do |node|
        if node.to_s.start_with?('@')
          add_error 'replace instance variable with local variable'
        end
      end
    end
  end
end
