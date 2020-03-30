# frozen_string_literal: true

module RailsBestPractices
  module Prepares
    # Remember all gems in Gemfile
    class GemfilePrepare < Core::Check
      interesting_files GEMFILE_LOCK

      def initialize
        @gems = Prepares.gems
      end

      def check(_filename, content)
        content.split("\n").each do |line|
          if line =~ /([^ ]+) \((\d.*)\)/
            @gems << Core::Gem.new(Regexp.last_match(1), Regexp.last_match(2))
          end
        end
      end
    end
  end
end
