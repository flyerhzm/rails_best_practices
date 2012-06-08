# encoding: utf-8
require 'rails_best_practices/reviews/review'
module RailsBestPractices
  module Lexicals
    class LongLineCheck < Core::Check

      def initialize(options = {})
        super()
        @max_line_length = options['max_line_length'] || 120
      end
      # check if a line is over 100 characters
      #
      # @param [String] filename name of the file
      # @param [String] content content of the file
      def check(filename, content)
        # Only check ruby files
        if /\.rb$/ =~ filename
          line_no = 0
          content.each_line do |line|
            line_no += 1
            actual_line_length = line.length - 1
            if actual_line_length > @max_line_length
              add_error("line is longer than #{@max_line_length} characters (#{actual_line_length} characters)", filename, line_no)
            end
          end
        end
      end
    end
  end
end
