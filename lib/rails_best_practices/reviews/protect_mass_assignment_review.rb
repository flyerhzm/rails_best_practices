# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review model files to make sure to use attr_accessible or attr_protected to protect mass assignment.
    #
    # See the best practices details here http://rails-bestpractices.com/posts/148-protect-mass-assignment.
    #
    # Implmentation:
    #
    # Review process:
    #   check class node to see if there is a command with message attr_accessible or attr_protected.
    class ProtectMassAssignmentReview < Review
      interesting_nodes :class
      interesting_files MODEL_FILES

      def url
        "http://rails-bestpractices.com/posts/148-protect-mass-assignment"
      end

      # check class node, grep all command nodes, if none of them is with message attr_accessible or attr_protected,
      # then it should add attr_accessible or attr_protected to protect mass assignment.
      def start_class(node)
        if node.grep_node(:sexp_type => :command, :message => ["attr_accessible", "attr_protected"]).blank?
          add_error "protect mass assignment"
        end
      end
    end
  end
end
