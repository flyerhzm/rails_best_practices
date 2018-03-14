# encoding: utf-8
# frozen_string_literal: true

module RailsBestPractices
  module Lexicals
    # Keep lines fewer than 80 characters.
    class LongLineCheck < Core::Check
      interesting_files ALL_FILES

      def initialize(options = {})
        super(options)
        @max_line_length = options['max_line_length'] || 80
      end

      # check if a line is over 80 characters
      #
      # @param [String] filename name of the file
      # @param [String] content content of the file
      def check(filename, content)
        # Only check ruby files
        if /\.rb$/ =~ filename
          line_no = 0
          content.each_line do |line|
            line_no += 1
            actual_line_length = line.sub(/\s+$/, '').length
            if actual_line_length > @max_line_length
              add_error("line is longer than #{@max_line_length} characters (#{actual_line_length} characters)", filename, line_no)
            end
          end
        end
      end
    end
  end
end
