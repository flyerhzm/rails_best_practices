# encoding: utf-8
module RailsBestPractices
  module Reviews
    # Review model files to make sure finders are on their own model.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/13-keep-finders-on-their-own-model.
    #
    # Implementation:
    #
    # Review process:
    #   check all call nodes in model files.
    #
    #   if the call node is a finder (find, all, first or last),
    #   and the it calls the other model,
    #   and there is a hash argument for finder,
    #   then it should keep finders on its own model.
    class KeepFindersOnTheirOwnModelReview < Review
      interesting_nodes :method_add_arg
      interesting_files MODEL_FILES
      url "http://rails-bestpractices.com/posts/13-keep-finders-on-their-own-model"

      FINDERS = %w(find all first last)

      # check all the call nodes to see if there is a finder for other model.
      #
      # if the call node is
      #
      # 1. the message of call node is one of the find, all, first or last
      # 2. the receiver of call node is also a call node (it's the other model)
      # 3. the any of its arguments is a hash (complex finder)
      #
      # then it should keep finders on its own model.
      add_callback :start_method_add_arg do |node|
        add_error "keep finders on their own model" if other_finder?(node)
      end

      private
        # check if the call node is the finder of other model.
        #
        # the message of the node should be one of find, all, first or last,
        # and the receiver of the node should be with message :call (this is the other model),
        # and any of its arguments is a hash,
        # then it is the finder of other model.
        def other_finder?(node)
          FINDERS.include?(node[1].message.to_s) &&
            :call == node[1].receiver.sexp_type &&
            node.arguments.grep_nodes_count(sexp_type: :bare_assoc_hash) > 0
        end
    end
  end
end
