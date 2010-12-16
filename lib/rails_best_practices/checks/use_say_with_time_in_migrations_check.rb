# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a migration file to make sure to use say or say_with_time for customized data changes to produce a more readable output.
    #
    # See the best practice detials here http://rails-bestpractices.com/posts/46-use-say-and-say_with_time-in-migrations-to-make-a-useful-migration-log.
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   check class method define nodes (self.up or self.down).
    #   if there is a method call in the class method definition,
    #   and the message of method call is not say, say_with_time and default migration methods (such as add_column and create_table),
    #   then the method call should be wrapped by say or say_with_time.
    class UseSayWithTimeInMigrationsCheck < Check

      DEFAULT_MIGRATION_METHODS = [:add_column, :add_index, :add_timestamps, :change_column, :change_column_default, :change_table, :create_table, :drop_table, :remove_column, :remove_index, :remove_timestamps, :rename_column, :rename_index, :rename_table]
      WITH_SAY_METHODS = DEFAULT_MIGRATION_METHODS + [:say, :say_with_time]


      def interesting_review_nodes
        [:defs]
      end

      def interesting_review_files
        MIGRATION_FILES
      end

      # check a class method define node to see if there are method calls that need to be wrapped by :say or :say_with_time in review process.
      #
      # it will check the first block node,
      # if any method call whose message is not default migration methods in the block node, like
      #
      #     s(:defs, s(:self), :up, s(:args),
      #       s(:scope,
      #         s(:block,
      #           s(:iter,
      #             s(:call, s(:const, :User), :find_each, s(:arglist)),
      #             s(:lasgn, :user),
      #             s(:block,
      #               s(:masgn,
      #                 s(:array,
      #                   s(:attrasgn, s(:lvar, :user), :first_name=, s(:arglist)),
      #                   s(:attrasgn, s(:lvar, :user), :last_name=, s(:arglist))
      #                 ),
      #                 s(:to_ary,
      #                   s(:call,
      #                     s(:call, s(:lvar, :user), :full_name, s(:arglist)),
      #                     :split,
      #                     s(:arglist, s(:str, " "))
      #                   )
      #                 )
      #               ),
      #               s(:call, s(:lvar, :user), :save, s(:arglist))
      #             )
      #           )
      #         )
      #       )
      #     )
      #
      # then such method call should be wrapped by say or say_with_time
      def review_start_defs(node)
        block_node = node.grep_node(:node_type => :block)
        block_node.body.each do |child_node|
          if :iter == child_node.node_type
            subject_node = child_node.subject
            if :call == subject_node.node_type && !WITH_SAY_METHODS.include?(subject_node.message)
              add_error("use say with time in migrations", subject_node.file, subject_node.line)
            end
          end
        end
      end
    end
  end
end
