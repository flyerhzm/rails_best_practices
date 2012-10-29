# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review all code to make sure we don't rescue Exception
    # This is a common mistake by Java or C# devs in ruby.
    #
    # See the best practice details here http://stackoverflow.com/questions/10048173/why-is-it-bad-style-to-rescue-exception-e-in-ruby
    #
    # Implementation:
    #
    # Review process:
    #   check all rescue node to see if its type is Exception
    class NotRescueExceptionReview < Review
      interesting_nodes :rescue
      interesting_files ALL_FILES
      url "http://stackoverflow.com/questions/10048173/why-is-it-bad-style-to-rescue-exception-e-in-ruby"

      # check rescue node to see if its type is Exception
      add_callback :start_rescue do |node|
        rescue_args = node[1]
        if rescue_args
          rescue_type = rescue_args.first
          if rescue_type && rescue_type.first == :var_ref
            rescue_type_var = rescue_type[1]
            if rescue_type_var.first == :@const
              if "Exception" == rescue_type_var[1]
                # 'rescue' nodes do not have line-number info, but the rescue_type
                # node does.
                add_error "not rescue Exception", node.file, rescue_type.line
              end
            end
          end
        end
      end
    end
  end
end
