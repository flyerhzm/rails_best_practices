# encoding: utf-8
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
    #   check al method method_add_arg nodes to see if there is a complex options_for_select helper.
    #
    #   if the message of the method_add_arg node is options_for_select,
    #   and the first argument of the method_add_arg node is array,
    #   and the size of the array is greater than array_count defined,
    #   then the options_for_select method should be moved into helper.
    class MoveCodeIntoHelperReview < Review
      interesting_nodes :method_add_arg
      interesting_files VIEW_FILES
      url "http://rails-bestpractices.com/posts/26-move-code-into-helper"

      def initialize(options = {})
        super(options)
        @array_count = options['array_count'] || 3
      end

      # check method_add_arg node with message options_for_select (sorry we only check options_for_select helper now).
      #
      # if the first argument of options_for_select method call is an array,
      # and the size of the array is more than @array_count defined,
      # then the options_for_select helper should be moved into helper.
      add_callback :start_method_add_arg do |node|
        add_error "move code into helper (array_count >= #{@array_count})" if complex_select_options?(node)
      end

      private
        # check if the arguments of options_for_select are complex.
        #
        # if the first argument is an array,
        # and the size of array is greater than @array_count you defined,
        # then it is complext.
        def complex_select_options?(node)
          "options_for_select" == node[1].message.to_s &&
            :array == node.arguments.all.first.sexp_type &&
            node.arguments.all.first.array_size > @array_count
        end
    end
  end
end
