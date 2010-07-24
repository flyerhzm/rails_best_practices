require 'optparse'


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

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.parse!
end

runner = RailsBestPractices::Core::Runner.new
runner.set_debug if options['debug']

files = RailsBestPractices::analyze_files(ARGV, options)
files.each { |file| runner.check_file(file) }

runner.errors.each {|error| puts error}
puts "\nPlease go to http://rails-bestpractices.com to see more useful Rails Best Practices."
if runner.errors.size > 0
  puts "\nFound #{runner.errors.size} errors."
end

exit runner.errors.size
