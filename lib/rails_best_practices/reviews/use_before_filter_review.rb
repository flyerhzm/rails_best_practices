# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review a controller file to make sure to use before_filter to remove duplicated first code line in different action.
    #
    # See the best practice detailed here http://rails-bestpractices.com/posts/22-use-before_filter.
    #
    # Implementation:
    #
    # Review process:
    #   review all first code line in method definitions (actions),
    #   if they are duplicated, then they should be moved to before_filter.
    class UseBeforeFilterReview < Review

      PROTECTED_PRIVATE_CALLS = [[:call, nil, :protected, [:arglist]], [:call, nil, :private, [:arglist]]]

      def url
        "http://rails-bestpractices.com/posts/22-use-before_filter"
      end

      def interesting_review_nodes
        [:class]
      end

      def interesting_review_files
        CONTROLLER_FILES
      end

      # review class define node to see if there are method define nodes whose first code line are duplicated in review process.
      #
      # it will review every defn nodes in the class node until protected or private identification,
      # if there are defn nodes who have the same first code line, like
      #
      #     s(:class, :PostsController, s(:const, :ApplicationController),
      #       s(:scope,
      #         s(:block,
      #           s(:defn, :show, s(:args),
      #             s(:scope,
      #               s(:block,
      #                 s(:iasgn, :@post,
      #                   s(:call,
      #                     s(:call, s(:call, nil, :current_user, s(:arglist)), :posts, s(:arglist)),
      #                     :find,
      #                     s(:arglist,
      #                       s(:call, s(:call, nil, :params, s(:arglist)), :[], s(:arglist, s(:lit, :id)))
      #                     )
      #                   )
      #                 )
      #               )
      #             )
      #           ),
      #           s(:defn, :edit, s(:args),
      #             s(:scope,
      #               s(:block,
      #                 s(:iasgn, :@post,
      #                   s(:call,
      #                     s(:call, s(:call, nil, :current_user, s(:arglist)), :posts, s(:arglist)),
      #                     :find,
      #                     s(:arglist,
      #                       s(:call, s(:call, nil, :params, s(:arglist)), :[], s(:arglist, s(:lit, :id)))
      #                     )
      #                   )
      #                 )
      #               )
      #             )
      #           )
      #         )
      #       )
      #     )
      #
      # then these duplicated first code lines should be moved to before_filter.
      def review_start_class(class_node)
        @first_sentences = {}

        class_node.body.children.each do |child_node|
          break if PROTECTED_PRIVATE_CALLS.include? child_node
          remember_first_sentence(child_node) if :defn == child_node.node_type
        end
        @first_sentences.each do |first_sentence, defn_nodes|
          if defn_nodes.size > 1
            add_error "use before_filter for #{defn_nodes.collect(&:method_name).join(',')}", class_node.file, defn_nodes.collect(&:line).join(',')
          end
        end
      end

      private
        # review method define node, and remember the first sentence.
        # first sentence may be :iasgn, :lasgn, :attrasgn, :call node, like
        #
        #     s(:defn, :show, s(:args),
        #       s(:scope,
        #         s(:block,
        #           s(:iasgn, :@post,
        #             s(:call,
        #               s(:call, s(:call, nil, :current_user, s(:arglist)), :posts, s(:arglist)),
        #               :find,
        #               s(:arglist,
        #                 s(:call, s(:call, nil, :params, s(:arglist)), :[], s(:arglist, s(:lit, :id)))
        #               )
        #             )
        #           )
        #         )
        #       )
        #     )
        #
        # the first sentence of defn node is :iasgn node.
        def remember_first_sentence(defn_node)
          first_sentence = defn_node.body[1]
          unless first_sentence == s(:nil)
            @first_sentences[first_sentence] ||= []
            @first_sentences[first_sentence] << defn_node
          end
        end
    end
  end
end
