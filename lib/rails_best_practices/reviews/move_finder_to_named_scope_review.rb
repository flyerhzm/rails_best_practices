# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review a controller file to make sure there are no complex finder.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/1-move-finder-to-named_scope.
    #
    # Implementation:
    #
    # Review process:
    #   check all method method_add_arg nodes in controller files.
    #   if there is any call node with message find, all, first or last,
    #   and it has a hash argument,
    #   then it is a complex finder, and should be moved to model's named scope.
    class MoveFinderToNamedScopeReview < Review
      interesting_nodes :method_add_arg
      interesting_files CONTROLLER_FILES

      FINDERS = %w(find all first last)

      def url
        "http://rails-bestpractices.com/posts/1-move-finder-to-named_scope"
      end

      # check method_add_ag node if its message is one of find, all, first or last,
      # and it has a hash argument,
      # then the call node is the finder that should be moved to model's named_scope.
      def start_method_add_arg(node)
        add_error "move finder to named_scope" if finder?(node)
      end

      private
        # check if the method_add_arg node is a finder.
        #
        # if the subject of method_add_arg node is a constant,
        # and the message of call method_add_arg is one of find, all, first or last,
        # and any of its arguments is a hash,
        # then it is a finder.
        def finder?(node)
          FINDERS.include?(node[1].message.to_s) &&
            :call == node[1].sexp_type &&
            node.arguments.grep_nodes_count(sexp_type: :bare_assoc_hash) > 0
        end
    end
  end
end
