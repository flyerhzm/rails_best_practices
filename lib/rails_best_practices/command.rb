require 'optparse'

def expand_dirs_to_files *dirs
  extensions = ['rb', 'builder']

  dirs.flatten.map { |p|
    if File.directory? p
      Dir[File.join(p, '**', "*{#{extensions.join(',')}}")]
    else
      p
    end
  }.flatten.sort
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: rails_best_practices [options]"
  
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.parse!
end

runner = RailsBestPractices::Core::Runner.new
expand_dirs_to_files(ARGV).each.each { |file| runner.check_file(file) }
runner.errors.each {|error| puts error}
puts "\nFound #{runner.errors.size} errors."

exit runner.errors.size
