# encoding: utf-8
require 'optparse'
require 'progressbar'
require 'colored'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: rails_best_practices [options]"
  
  opts.on("-d", "--debug", "Debug mode") do
    options['debug'] = true
  end

  ['vendor', 'spec', 'test', 'stories'].each do |pattern|
    opts.on("--#{pattern}", "include #{pattern} files") do
      options[pattern] = true
    end
  end
  
  opts.on_tail('-v', '--version', 'Show this version') do
    puts File.read(File.dirname(__FILE__) + '/../../VERSION')
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

  opts.parse!
end

runner = RailsBestPractices::Core::Runner.new
runner.set_debug if options['debug']

files = RailsBestPractices::analyze_files(ARGV, options)
bar = ProgressBar.new('Analyzing', files.size)
files.each { |file| runner.check_file(file); bar.inc }
bar.finish

runner.errors.each {|error| puts error.to_s.red}
puts "\nPlease go to http://rails-bestpractices.com to see more useful Rails Best Practices.".green
if runner.errors.size > 0
  puts "\nFound #{runner.errors.size} errors.".red
end

exit runner.errors.size
