# encoding: utf-8
module RailsBestPractices
  module Core
    # Error is the violation to rails best practice.
    #
    # it indicates the filenname, line number and error message for the violation.
    class Error
      attr_reader :filename, :line_number, :message, :type, :url
      attr_accessor :git_commit, :git_username, :hg_commit, :hg_username

      def initialize(filename, line_number, message, type, url = nil)
        @filename = filename
        @line_number = line_number
        @message = message
        @type = type
        @url = url
      end

      def short_filename
        filename.sub(Core::Runner.base_path, '').sub(/^\/+/, '')
      end

      def first_line_number
        line_number.split(',').first
      end

      def to_s
        "#{@filename}:#{@line_number} - #{@message}"
      end
    end
  end
end
