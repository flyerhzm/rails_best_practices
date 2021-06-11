# frozen_string_literal: true

module RailsBestPractices
  module InlineDisables
    class CommentRipper < Ripper::SexpBuilder
      attr_reader :comments

      def initialize(*arg)
        super
        @comments = []
      end

      def on_comment(*arg)
        # [sexp_type, statement, [lineno, column]] = super
        comments << super
      end
    end
  end
end
