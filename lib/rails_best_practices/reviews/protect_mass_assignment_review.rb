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

      # check class node, grep all command nodes,
      # if config.active_record.whitelist_attributes is not set true,
      # and if none of them is with message attr_accessible or attr_protected,
      # and if not use devise or authlogic,
      # then it should add attr_accessible or attr_protected to protect mass assignment.
      def start_class(node)
        if !whitelist_attributes_config? && !rails_builtin?(node) && !devise?(node) && !authlogic?(node) && is_active_record?(node)
          add_error "protect mass assignment"
        end
      end

      private
        def whitelist_attributes_config?
          Prepares.configs["config.active_record.whitelist_attributes"] == "true"
        end

        def rails_builtin?(node)
          node.grep_node(sexp_type: [:vcall, :var_ref], to_s: "attr_accessible").present? ||
          node.grep_node(sexp_type: :command, message: %w(attr_accessible attr_protected)).present?
        end

        def devise?(node)
          node.grep_node(sexp_type: :command, message: "devise").present?
        end

        def authlogic?(node)
         node.grep_node(sexp_type: [:vcall, :var_ref], to_s: "acts_as_authentic").present? ||
         node.grep_node(sexp_type: :fcall, message: "acts_as_authentic").present?
        end

        def is_active_record?(node)
          node.grep_node(sexp_type: [:const_path_ref, :@const], to_s: "ActiveRecord::Base").present?
        end

        def is_active_record?(node)
          node.grep_node(:sexp_type => [:const_path_ref, :@const], :to_s => "ActiveRecord::Base").present?
        end
    end
  end
end
