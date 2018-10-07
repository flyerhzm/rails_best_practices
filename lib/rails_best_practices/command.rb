# frozen_string_literal: true

require 'optparse'
options = RailsBestPractices::OptionParser.parse!
if !ARGV.empty? && !File.exist?(ARGV.first)
  puts "#{ARGV.first} doesn't exist"
  exit 1
end

if options['generate']
  RailsBestPractices::Analyzer.new(ARGV.first).generate
else
  analyzer = RailsBestPractices::Analyzer.new(ARGV.first, options)
  analyzer.analyze
  analyzer.output
  exit !analyzer.runner.errors.empty? ? 1 : 0
end
