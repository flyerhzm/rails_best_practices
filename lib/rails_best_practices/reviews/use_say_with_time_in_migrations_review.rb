# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review a migration file to make sure to use say or say_with_time for customized data changes
    # to produce a more readable output.
    #
    # See the best practice detials here https://rails-bestpractices.com/posts/2010/08/19/use-say-and-say_with_time-in-migrations-to-make-a-useful-migration-log/
    #
    # Implementation:
    #
    # Review process:
    #   check class method define nodes (self.up or self.down).
    #   if there is a method call in the class method definition,
    #   and the message of method call is not say, say_with_time and default migration methods
    #   (such as add_column and create_table), then the method call should be wrapped by say or say_with_time.
    class UseSayWithTimeInMigrationsReview < Review
      interesting_nodes :defs
      interesting_files MIGRATION_FILES
      url 'https://rails-bestpractices.com/posts/2010/08/19/use-say-and-say_with_time-in-migrations-to-make-a-useful-migration-log/'

      WITH_SAY_METHODS = %w(say say_with_time)

      # check a class method define node to see if there are method calls that need to be wrapped by say
      # or say_with_time.
      #
      # it will check the first block node,
      # if any method call whose message is not default migration methods in the block node,
      # then such method call should be wrapped by say or say_with_time
      add_callback :start_defs do |node|
        node.body.statements.each do |child_node|
          next if child_node.grep_nodes_count(sexp_type: [:fcall, :command], message: WITH_SAY_METHODS) > 0

          receiver_node = if :method_add_block == child_node.sexp_type
                           child_node[1]
                         elsif :method_add_arg == child_node.sexp_type
                           child_node[1]
                         else
                           child_node
                         end
          if :call == receiver_node.sexp_type
            add_error('use say with time in migrations', node.file, child_node.line_number)
          end
        end
      end
    end
  end
end
