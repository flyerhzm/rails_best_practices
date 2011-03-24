# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review a view file to make sure there is no complex options_for_select message call.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/26-move-code-into-helper.
    #
    # TODO: we need a better soluation, any suggestion?
    #
    # Implementation:
    #
    # Review process:
    #   check al method calls to see if there is a complex options_for_select helper.
    #
    #   if the message of the call node is options_for_select,
    #   and the first argument of the call node is array,
    #   and the size of the array is greater than array_count defined,
    #   then the options_for_select method should be moved into helper.
    class MoveCodeIntoHelperReview < Review
      def url
        "http://rails-bestpractices.com/posts/26-move-code-into-helper"
      end

      def interesting_nodes
        [:call]
      end

      def interesting_files
        VIEW_FILES
      end

      def initialize(options = {})
        super()
        @array_count = options['array_count'] || 3
      end

      # check call node with message options_for_select (sorry we only check options_for_select helper now).
      #
      # if the first argument of options_for_select method call is an array,
      # and the size of the array is more than @array_count defined,
      # then the options_for_select helper should be moved into helper.
      def start_call(node)
        add_error "move code into helper (array_count >= #{@array_count})" if complex_select_options?(node)
      end

      private
        # check if the arguments of options_for_select are complex.
        #
        # if the first argument is an array,
        # and the size of array is greater than @array_count you defined,
        # then it is complext, e.g.
        #
        #     s(:call, nil, :options_for_select,
        #       s(:arglist,
        #         s(:array,
        #           s(:array,
        #             s(:call, nil, :t, s(:arglist, s(:lit, :draft))),
        #             s(:str, "draft")
        #           ),
        #           s(:array,
        #             s(:call, nil, :t, s(:arglist, s(:lit, :published))),
        #             s(:str, "published")
        #           )
        #         ),
        #         s(:call,
        #           s(:call, nil, :params, s(:arglist)),
        #           :[],
        #           s(:arglist, s(:lit, :default_state))
        #         )
        #       )
        #     )
        def complex_select_options?(node)
          :options_for_select == node.message && :array == node.arguments[1].node_type && node.arguments[1].size > @array_count
        end
    end
  end
end
