# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Check ruby 1.8 style hash and suggest to change hash syntax to 1.9.
    #
    # Review process:
    #   check hash nodes in all files,
    #   if the sexp type of hash key nodes is not :@lable,
    #   then the hash is ruby 1.8 style.
    class HashSyntaxReview < Review
      interesting_nodes :hash, :bare_assoc_hash
      interesting_files ALL_FILES

      # check hash node to see if it is ruby 1.8 style.
      def start_hash(node)
        pair_nodes = node[1][1]

        if hash_is_18?(pair_nodes)
          add_error "change Hash Syntax to 1.9"
        end
      end

      # check bare_assoc_hash node to see if it is ruby 1.8 style.
      def start_bare_assoc_hash(node)
        pair_nodes = node[1]

        if hash_is_18?(pair_nodes)
          add_error "change Hash Syntax to 1.9"
        end
      end

      protected
        # check if hash key/value pairs are ruby 1.8 style.
        #
        # hash key of ruby 1.9 style is :@label,
        # so if it is not, then it is ruby 1.8 style.
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

