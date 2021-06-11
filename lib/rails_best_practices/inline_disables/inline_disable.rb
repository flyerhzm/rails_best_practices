# frozen_string_literal: true

module RailsBestPractices
  module InlineDisables
    class InlineDisable < Core::Check
      interesting_files ALL_FILES
      url '#'

      def initialize(*args)
        super
        @disabled_errors = []
      end

      def check(filename, content)
        comments = CommentRipper.new(content).tap(&:parse).comments
        comments.each do |_sexp_type, statement, (line_number, _column)|
          add_as_disable_errors(filename, statement, line_number)
        end
      end

      def disabled?(error)
        error_key = [error.filename, error.line_number, error.type.split('::').last].join('-')
        disabled_error_keys.include?(error_key)
      end

      private

      def disabled_error_keys
        @disabled_error_keys ||= Set.new(@disabled_errors.map { |e| [e.filename, e.line_number, e.type].join('-') })
      end

      def add_as_disable_errors(filename, statement, line_number)
        match = statement.match(/rails_b(?:est_)?p(?:ractices)?:disable (.*)/)
        return unless match

        check_names = match[1].split(',')
        check_names.each do |check_name|
          add_as_disable_error(filename, check_name.gsub(/Check$/, 'Review'), line_number)
        end
      end

      def add_as_disable_error(filename, check_name, line_number)
        @disabled_errors <<
          RailsBestPractices::Core::Error.new(
            filename: filename, line_number: line_number, message: 'disable by inline comment', type: check_name, url: url
          )
      end
    end
  end
end
