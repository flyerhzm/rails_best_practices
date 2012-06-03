# encoding: utf-8
require 'rails_best_practices/reviews/review'
module RailsBestPractices
  module Lexicals
    class HashSyntaxCheck < Core::Check

      # check if the content of file contains a 1.8 Hash.
      #
      # @param [String] filename name of the file
      # @param [String] content content of the file
      def check(filename, content)
        if content =~ /:[_a-z]+(\ *)=>/
          line_no = $`.count("\n") + 1
          add_error("change Hash Syntax to 1.9", filename, line_no)
        end
      end
    end
  end
end