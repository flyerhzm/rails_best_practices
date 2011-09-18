# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review a view file to make sure there is no finder, finder should be moved to controller.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/24-move-code-into-controller.
    #
    # Implementation:
    #
    # Review process:
    #   only check all view files to see if there are finders, then the finders should be moved to controller.
    class MoveCodeIntoControllerReview < Review

      FINDERS = %w(find all first last)

      def url
        "http://rails-bestpractices.com/posts/24-move-code-into-controller"
      end

      def interesting_nodes
        [:call]
      end

      def interesting_files
        VIEW_FILES
      end

      # check call nodes.
      #
      # if the subject of the call node is a constant,
      # and the message of the call node is one of the find, all, first and last,
      # then it is a finder and should be moved to controller.
      def start_call(node)
        add_error "move code into controller" if finder?(node)
      end

      private
        # check if the node is a finder call node.
        def finder?(node)
          :var_ref == node.subject.sexp_type &&
            :@const == node.subject[1].sexp_type && FINDERS.include?(node.message.to_s)
        end
    end
  end
end
