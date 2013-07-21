# encoding: utf-8
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

      VALID_SYMBOL_KEY = /\A[@$_A-Za-z]([_\w]*[!_=?\w])?\z/

      # check hash node to see if it is ruby 1.8 style.
      add_callback :start_hash, :start_bare_assoc_hash do |node|
        if !empty_hash?(node) && hash_is_18?(node) && valid_keys?(node)
          add_error "change Hash Syntax to 1.9"
        end
      end

      protected
        # check if hash node is empty.
        def empty_hash?(node)
          s(:hash, nil) == node || s(:bare_assoc_hash, nil) == node
        end

        # check if hash key/value pairs are ruby 1.8 style.
        def hash_is_18?(node)
          pair_nodes = :hash == node.sexp_type ? node[1][1] : node[1]
          return false if pair_nodes.blank?

          pair_nodes.any? { |pair_node| :symbol_literal == pair_node[1].sexp_type }
        end

        # check if the hash keys are valid to be converted to ruby 1.9
        # syntax.
        def valid_keys?(node)
          node.hash_keys.all? { |key| key =~ VALID_SYMBOL_KEY }
        end
    end
  end
end
