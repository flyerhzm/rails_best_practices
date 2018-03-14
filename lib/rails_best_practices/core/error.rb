# encoding: utf-8
# frozen_string_literal: true

module RailsBestPractices
  module Core
    # Error is the violation to rails best practice.
    #
    # it indicates the filenname, line number and error message for the violation.
    class Error < CodeAnalyzer::Warning
      attr_reader :type, :url
      attr_accessor :git_commit, :git_username, :hg_commit, :hg_username

      def initialize(options = {})
        super
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
    end
  end
end
