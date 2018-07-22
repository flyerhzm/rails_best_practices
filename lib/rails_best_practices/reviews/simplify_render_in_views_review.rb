# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review a view file to make sure using simplified syntax for render.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/12/04/simplify-render-in-views/
    #
    # Implementation:
    #
    # Review process:
    #   check all render method commands in view files,
    #   if there is a key 'partial' in the argument, then they should be replaced by simplified syntax.
    class SimplifyRenderInViewsReview < Review
      interesting_nodes :command
      interesting_files VIEW_FILES
      url 'https://rails-bestpractices.com/posts/2010/12/04/simplify-render-in-views/'

      VALID_KEYS = %w[object collection locals].freeze

      # check command node in view file,
      # if its message is render and the arguments contain a key partial,
      # then it should be replaced by simplified syntax.
      add_callback :start_command do |node|
        if 'render' == node.message.to_s
          hash_node =  node.arguments.all.first
          if hash_node && :bare_assoc_hash == hash_node.sexp_type &&
             include_partial?(hash_node) && valid_hash?(hash_node)
            add_error 'simplify render in views'
          end
        end
      end

      protected

      def include_partial?(hash_node)
        hash_node.hash_keys.include?('partial') && !hash_node.hash_value('partial').to_s.include?('/')
      end

      def valid_hash?(hash_node)
        keys = hash_node.hash_keys
        keys.delete('partial')
        (keys - VALID_KEYS).empty?
      end
    end
  end
end
