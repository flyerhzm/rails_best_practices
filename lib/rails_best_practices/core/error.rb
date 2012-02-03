# encoding: utf-8
module RailsBestPractices
  module Core
    # Error is the violation to rails best practice.
    #
    # it indicates the filenname, line number and error message for the violation.
    class Error
      attr_reader :filename, :line_number, :message, :type, :url
      attr_accessor :git_commit, :git_username, :hg_commit, :hg_username

      def initialize(options={})
        @filename = options[:filename]
        @line_number = options[:line_number]
        @message = options[:message]
        @type = options[:type]
        @url = options[:url]
        @git_commit = options[:git_commit]
        @git_username = options[:git_username]
        @hg_commit = options[:hg_commit]
        @hg_username = options[:hg_username]
      end

      def short_filename
        File.expand_path(filename)[File.expand_path(Core::Runner.base_path).size..-1].sub(/^\//, '')
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
