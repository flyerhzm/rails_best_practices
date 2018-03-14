# frozen_string_literal: true

module RailsBestPractices
  module Lexicals
    # Make sure there are no tabs in files.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2011/07/04/remove-tab/
    class RemoveTabCheck < Core::Check
      interesting_files ALL_FILES
      url 'https://rails-bestpractices.com/posts/2011/07/04/remove-tab/'

      # check if the content of file contains a tab.
      #
      # @param [String] filename name of the file
      # @param [String] content content of the file
      def check(filename, content)
        if content =~ /\t/m
          line_no = $`.count("\n") + 1
          add_error('remove tab, use spaces instead', filename, line_no)
        end
      end
    end
  end
end
