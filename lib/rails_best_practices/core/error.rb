# encoding: utf-8
module RailsBestPractices
  module Core
    # Error is the violation to rails best practice.
    #
    # it indicates the filenname, line number and error message for the violation.
    class Error
      attr_reader :filename, :line_number, :message

      def initialize(filename, line_number, message)
        @filename = filename
        @line_number = line_number
        @message = message
      end

      def to_s
        "#{@filename}:#{@line_number} - #{@message}"
      end
    end
  end
end
