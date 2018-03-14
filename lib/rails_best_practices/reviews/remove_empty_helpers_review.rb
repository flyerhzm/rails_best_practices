# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review a helper file to make sure it is not an empty moduel.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2011/04/09/remove-empty-helpers/
    #
    # Implementation:
    #
    # Review process:
    #   check all helper files, if the body of module is nil, then the helper file should be removed.
    class RemoveEmptyHelpersReview < Review
      interesting_nodes :module
      interesting_files HELPER_FILES
      url 'https://rails-bestpractices.com/posts/2011/04/09/remove-empty-helpers/'

      # check the body of module node, if it is nil, then it should be removed.
      add_callback :start_module do |module_node|
        if 'ApplicationHelper' != module_node.module_name.to_s && empty_body?(module_node)
          add_error 'remove empty helpers'
        end
      end

      protected

        def empty_body?(module_node)
          s(:bodystmt, s(:stmts_add, s(:stmts_new), s(:void_stmt)), nil, nil, nil) == module_node.body
        end
    end
  end
end
