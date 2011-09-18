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
    #   check all first code line in method definitions (actions),
    #   if they are duplicated, then they should be moved to before_filter.
    class UseBeforeFilterReview < Review
      def url
        "http://rails-bestpractices.com/posts/22-use-before_filter"
      end

      def interesting_nodes
        [:class]
      end

      def interesting_files
        CONTROLLER_FILES
      end

      def initialize(options = {})
        super()
        @customize_count = options['customize_count'] || 1
      end

      # check class define node to see if there are method define nodes whose first code line are duplicated.
      #
      # it will check every def nodes in the class node until protected or private identification,
      # if there are defn nodes who have the same first code line,
      # then these duplicated first code lines should be moved to before_filter.
      def start_class(node)
        @first_sentences = {}

        node.body.statements.each do |statement_node|
          break if :var_ref == statement_node.sexp_type && ["protected", "private"].include?(statement_node.to_s)
          remember_first_sentence(statement_node) if :def == statement_node.sexp_type
        end
        @first_sentences.each do |first_sentence, def_nodes|
          if def_nodes.size > @customize_count
            add_error "use before_filter for #{def_nodes.map { |node| node.method_name.to_s }.join(',')}", node.file, def_nodes.map(&:line).join(',')
          end
        end
      end

      private
        # check method define node, and remember the first sentence.
        def remember_first_sentence(node)
          first_sentence = node.body.statements.first
          return unless first_sentence
          first_sentence.remove_line_and_column!
          unless first_sentence == s(:nil)
            @first_sentences[first_sentence] ||= []
            @first_sentences[first_sentence] << node
          end
        end
    end
  end
end
