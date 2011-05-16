# encoding: utf-8
module RailsBestPractices
  module Core
    # Error is the violation to rails best practice.
    #
    # it indicates the filenname, line number and error message for the violation.
    class Error
      attr_reader :filename, :line_number, :message, :url

      def initialize(filename, line_number, message, url = nil)
        @filename = filename
        @line_number = line_number
        @message = message
        @url = url
      end

      def to_s
        "#{@filename}:#{@line_number} - #{@message}"
      end

      def ignore?
        code_comment =~ /ignore_rbp/
      end

    private

      def code_comment
        code_line = File.new(@filename).readlines[@line_number.to_i - 1]
        pos = code_line.index '#'
        pos && code_line[pos + 1..-1]
      end
    end
  end
end
