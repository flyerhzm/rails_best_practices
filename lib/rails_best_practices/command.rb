require 'optparse'

def expand_dirs_to_files *dirs
  extensions = ['rb', 'erb', 'builder']

  dirs.flatten.map { |p|
    if File.directory? p
      Dir[File.join(p, '**', "*.{#{extensions.join(',')}}")]
    else
      p
    end
  }.flatten
end

# for law_of_demeter_check
def model_first_sort files
  files.sort { |a, b|
    if a =~ /models\/.*rb/
      -1
    elsif b =~ /models\/.*rb/
      1
    else
      a <=> b
    end
  }
end

# for always_add_db_index_check
def add_duplicate_migrations files
  migration_files = files.select { |file| file.index("db/migrate") }
  (files << migration_files).flatten
end

def ignore_files files, pattern
  files.reject { |file| file.index(pattern) }
end

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

files = expand_dirs_to_files(ARGV)
files = model_first_sort(files)
files = add_duplicate_migrations(files)
['vendor', 'spec', 'test', 'stories'].each do |pattern|
  files = ignore_files(files, "#{pattern}/") unless options[pattern]
end
files.each { |file| runner.check_file(file) }

runner.errors.each {|error| puts error}
if runner.errors.size > 0
  puts "\ngo to http://wiki.github.com/flyerhzm/rails_best_practices to see how to solve these errors."
  puts "\nFound #{runner.errors.size} errors."
end

exit runner.errors.size
