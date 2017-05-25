# encoding: utf-8
module RailsBestPractices
  module Lexicals
    # Make sure there are no trailing whitespace in codes.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/12/02/remove-trailing-whitespace/
    class RemoveTrailingWhitespaceCheck < Core::Check
      interesting_files ALL_FILES
      url "https://rails-bestpractices.com/posts/2010/12/02/remove-trailing-whitespace/"

      # check if the content of file contain a trailing whitespace.
      #
      # @param [String] filename name of the file
      # @param [String] content content of the file
      def check(filename, content)
        if content =~ / +\n/m
          line_no = $`.count("\n") + 1
          add_error("remove trailing whitespace", filename, line_no)
        end
      end
    end
  end
end
