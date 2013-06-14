# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remember all gems in Gemfile
    class GemfilePrepare < Core::Check
      interesting_files GEMFILE_LOCK

      def initialize
        @gems = Prepares.gems
      end

      def check(filename, content)
        content.split("\n").each do |line|
          if line =~ /([^ ]+) \((\d.*)\)/
            @gems << Core::Gem.new($1, $2)
          end
        end
      end
    end
  end
end
