# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review a controller file to make sure to use before_filter to remove duplicated first code
    # line_number in different action.
    #
    # See the best practice detailed here https://rails-bestpractices.com/posts/2010/07/24/use-before_filter/
    #
    # Implementation:
    #
    # Review process:
    #   check all first code line_number in method definitions (actions),
    #   if they are duplicated, then they should be moved to before_filter.
    class UseBeforeFilterReview < Review
      interesting_nodes :class
      interesting_files CONTROLLER_FILES
      url 'https://rails-bestpractices.com/posts/2010/07/24/use-before_filter/'

      def initialize(options = {})
        super()
        @customize_count = options['customize_count'] || 2
      end

      # check class define node to see if there are method define nodes whose first code line_number are duplicated.
      #
      # it will check every def nodes in the class node until protected or private identification,
      # if there are defn nodes who have the same first code line_number,
      # then these duplicated first code line_numbers should be moved to before_filter.
      add_callback :start_class do |node|
        @first_sentences = {}

        node.body.statements.each do |statement_node|
          var_ref_or_vcall_included = %i[var_ref vcall].include?(statement_node.sexp_type)
          private_or_protected_included = %w[protected private].include?(statement_node.to_s)
          break if var_ref_or_vcall_included && private_or_protected_included
          remember_first_sentence(statement_node) if :def == statement_node.sexp_type
        end
        @first_sentences.each do |_first_sentence, def_nodes|
          next unless def_nodes.size > @customize_count
          add_error "use before_filter for #{def_nodes.map { |node| node.method_name.to_s }.join(',')}",
                    node.file,
                    def_nodes.map(&:line_number).join(',')
        end
      end

      private

        # check method define node, and remember the first sentence.
      def remember_first_sentence(node)
        first_sentence = node.body.statements.first
        return unless first_sentence
        first_sentence = first_sentence.remove_line_and_column
        unless first_sentence == s(:nil)
          @first_sentences[first_sentence] ||= []
          @first_sentences[first_sentence] << node
        end
      end
    end
  end
end
