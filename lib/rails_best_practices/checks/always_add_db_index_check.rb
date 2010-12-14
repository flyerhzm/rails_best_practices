# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check db/schema.rb file to make sure every reference key has a database index.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/21-always-add-db-index
    #
    # Implementation:
    #
    # Prepare process:
    #   none
    #
    # Review process:
    #   only check the call nodes and at the end of iter node in db/schema file,
    #   if the subject of call node is :create_table, then remember the table names
    #   if the subject of call node is :integer, then remember it as foreign key
    #   if the sujbect of call node is :string, the name of it is _type suffixed and there is an integer column _id suffixed, then remember it as polymorphic foreign key
    #   if the subject of call node is :add_index, then remember the index columns
    #   after all of these, at the end of iter node
    #
    #       ActiveRecord::Schema.define(:version => 20101201111111) do
    #         ......
    #       end
    #
    #   if there are any foreign keys not existed in index columns,
    #   then the foreign keys should add db index.
    class AlwaysAddDbIndexCheck < Check

      def interesting_review_nodes
        [:call, :iter]
      end

      def interesting_review_files
        /db\/schema.rb/
      end

      def initialize
        super
        @index_columns = {}
        @foreign_keys = {}
        @table_nodes = {}
      end

      # check call node in review process.
      #
      # if the message of call node is :create_table,
      # then remember the table name (@table_nodes) like
      #     {
      #       "comments" =>
      #         s(:call, nil, :create_table, s(:arglist, s(:str, "comments"), s(:hash, s(:lit, :force), s(:true))))
      #     }
      #
      # if the message of call node is :integer,
      # then remember it as a foreign key of last create table name.
      #
      # if the message of call node is :type and the name of argument is _type suffixed,
      # then remember it with _id suffixed column as polymorphic foreign key.
      #
      # the remember foreign keys (@foreign_keys) like
      #
      #   {
      #     "taggings" =>
      #       ["tag_id", ["taggable_id", "taggable_type"]]
      #   }
      #
      # if the message of call node is :add_index,
      # then remember it as index columns (@index_columns) like
      #
      #   {
      #     "comments" =>
      #       ["post_id", "user_id"]
      #   }
      def review_start_call(node)
        case node.message
        when :create_table
          remember_table_nodes(node)
        when :integer, :string
          remember_foreign_key_columns(node)
        when :add_index
          remember_index_columns(node)
        else
        end
      end

      # check at the end of iter node, like
      #
      #     s(:iter,
      #       s(:call,
      #         s(:colon2, s(:const, :ActiveRecord), :Schema),
      #         :define,
      #         s(:arglist, s(:hash, s(:lit, :version), s(:lit, 20100603080629)))
      #       ),
      #       nil,
      #       s(:iter,
      #         s(:call, nil, :create_table,
      #           s(:arglist, s(:str, "comments"), s(:hash, s(:lit, :force), s(:true)))
      #         ),
      #         s(:lasgn, :t),
      #         s(:block,
      #           s(:call, s(:lvar, :t), :string, s(:arglist, s(:str, "content")))
      #         )
      #       )
      #     )
      #
      # if the subject of iter node is with subject ActiveRecord::Schema,
      # it means we have completed the foreign keys and index columns parsing,
      # then we compare foreign keys and index columns.
      #
      # if there are any foreign keys not existed in index columns,
      # then we should add db index for that foreign keys.
      def review_end_iter(node)
        first_node = node.subject
        if :call == first_node.node_type && s(:colon2, s(:const, :ActiveRecord), :Schema) == first_node.subject
          remove_only_type_foreign_keys
          @foreign_keys.each do |table, foreign_key|
            table_node = @table_nodes[table]
            foreign_key.each do |column|
              if indexed?(table, column)
                add_error "always add db index (#{table} => [#{Array(column).join(', ')}])", table_node.file, table_node.line
              end
            end
          end
        end
      end

      private
        # remember the node as index columns
        #
        #     s(:call, nil, :add_index,
        #       s(:arglist,
        #         s(:str, "comments"),
        #         s(:array, s(:str, "post_id")),
        #         s(:hash, s(:lit, :name), s(:str, "index_comments_on_post_id"))
        #       )
        #     )
        #
        # the remember index columns are like
        #     {
        #       "comments" =>
        #         ["post_id", "user_id"]
        #     }
        def remember_index_columns(node)
          table_name = node.arguments[1].to_s
          index_column = eval(node.arguments[2].to_s)

          @index_columns[table_name] ||= []
          @index_columns[table_name] << (index_column.size == 1 ? index_column[0] : index_column)
        end

        # remember table nodes
        #
        # if the node is
        #
        #     s(:call, nil, :create_table,
        #       s(:arglist, s(:str, "comments"), s(:hash, s(:lit, :force), s(:true))))
        #
        # then the table nodes will be
        #
        #     {
        #       "comments" =>
        #         s(:call, nil, :create_table, s(:arglist, s(:str, "comments"), s(:hash, s(:lit, :force), s(:true))))
        #     }
        def remember_table_nodes(node)
          @table_name = node.arguments[1].to_s
          @table_nodes[@table_name] = node
        end


        # remember foreign key columns
        #
        # if the message of node is :integer,
        # then it is a foreign key, like
        #
        #     s(:call, s(:lvar, :t), :integer, s(:arglist, s(:str, "post_id")))
        #
        # if the message of node is :string, with _type suffixed and there is a _id suffixed column,
        # then they are polymorphic foreign key
        #
        #     s(:call, s(:lvar, :t), :integer, s(:arglist, s(:str, "taggable_id")))
        #     s(:call, s(:lvar, :t), :string, s(:arglist, s(:str, "taggable_type")))
        def remember_foreign_key_columns(node)
          table_name = @table_name
          foreign_key_column = node.arguments[1].to_s
          @foreign_keys[table_name] ||= []
          if foreign_key_column =~ /(.*?)_id$/
            if @foreign_keys[table_name].delete("#{$1}_type")
              @foreign_keys[table_name] << ["#{$1}_id", "#{$1}_type"]
            else
              @foreign_keys[table_name] << foreign_key_column
            end
          elsif foreign_key_column =~ /(.*?)_type$/
            if @foreign_keys[table_name].delete("#{$1}_id")
              @foreign_keys[table_name] << ["#{$1}_id", "#{$1}_type"]
            else
              @foreign_keys[table_name] << foreign_key_column
            end
          end
        end

        # remove the non foreign keys with only _type column.
        def remove_only_type_foreign_keys
          @foreign_keys.delete_if { |table, foreign_key|
            foreign_key.size == 1 && foreign_key[0] =~ /_type$/
          }
        end

        # check if the table's column is indexed.
        def indexed?(table, column)
          index_columns = @index_columns[table]
          !index_columns || !index_columns.any? { |e| greater_than_or_equal(Array(e), Array(column)) }
        end

        # check if more_array is greater than less_array or equal to less_array.
        def greater_than_or_equal(more_array, less_array)
          more_size = more_array.size
          less_size = less_array.size
          (more_array - less_array).size == more_size - less_size
        end
    end
  end
end
