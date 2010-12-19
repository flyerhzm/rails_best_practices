# encoding: utf-8
require 'optparse'

# Usage: rails_best_practices [options] path
#     -d, --debug                      Debug mode
#         --vendor                     include vendor files
#         --spec                       include spec files
#         --test                       include test files
#         --features                   include features files
#     -x, --exclude PATTERNS           Don't analyze files matching a pattern
#                                      (comma-separated regexp list)
#     -g, --generate                   Generate configuration yaml
#     -v, --version                    Show this version
#     -h, --help                       Show this message
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: rails_best_practices [options] path"

  opts.on("-d", "--debug", "Debug mode") do
    options['debug'] = true
  end

  ['vendor', 'spec', 'test', 'features'].each do |pattern|
    opts.on("--#{pattern}", "include #{pattern} files") do
      options[pattern] = true
    end
  end

  opts.on_tail('-v', '--version', 'Show this version') do
    require 'rails_best_practices/version'
    puts RailsBestPractices::VERSION
    exit
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.on("-x", "--exclude PATTERNS", "Don't analyze files matching a pattern", "(comma-separated regexp list)") do |list|
    begin
      options[:exclude] = list.split(/,/).map{|x| Regexp.new x}
    rescue RegexpError => e
      raise OptionParser::InvalidArgument, e.message
    end
  end

  opts.on("-g", "--generate", "Generate configuration yaml") do
    options[:generate] = true
  end

  opts.parse!
end

if options[:generate]
  RailsBestPractices.generate(ARGV.first)
else
  RailsBestPractices.start(ARGV.first, options)
end
