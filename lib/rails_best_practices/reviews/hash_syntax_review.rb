# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    class HashSyntaxReview < Review
      interesting_nodes :hash, :bare_assoc_hash
      interesting_files ALL_FILES

      def start_hash(node)
        pair_nodes = node[1][1]

        if hash_is_18?(pair_nodes)
          add_error "change Hash Syntax to 1.9"
        end
      end

      def start_bare_assoc_hash(node)
        pair_nodes = node[1]

        if hash_is_18?(pair_nodes)
          add_error "change Hash Syntax to 1.9"
        end
      end

      protected
        def hash_is_18?(pair_nodes)
          return false if pair_nodes.blank?

          pair_nodes.size.times do |i|
            if pair_nodes[i][1].sexp_type != :@label
              return true
            end
          end

          false
        end
    end
  end
end

