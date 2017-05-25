# encoding: utf-8
module RailsBestPractices
  module Reviews
    # Review all code to make sure we don't rescue Exception
    # This is a common mistake by Java or C# devs in ruby.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2012/11/01/don-t-rescue-exception-rescue-standarderror/
    #
    # Implementation:
    #
    # Review process:
    #   check all rescue node to see if its type is Exception
    class NotRescueExceptionReview < Review
      interesting_nodes :rescue
      interesting_files ALL_FILES
      url "https://rails-bestpractices.com/posts/2012/11/01/don-t-rescue-exception-rescue-standarderror/"

      # check rescue node to see if its type is Exception
      add_callback :start_rescue do |rescue_node|
        if rescue_node.exception_classes.any? { |rescue_class| "Exception" == rescue_class.to_s }
          add_error "Don't rescue Exception", rescue_node.file, rescue_node.exception_classes.first.line_number
        end
      end
    end
  end
end
