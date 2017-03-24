# encoding: utf-8
require "optparse"

# Usage: rails_best_practices [options] path
#    -d, --debug                      debug mode
#        --silent                     silent mode
#    -f, --format FORMAT              output format (text, html, yml, json, xml)
#        --output-file FILE           output html file for the analyzing result
#        --without-color              only output plain text without color
#        --with-textmate              open file by textmate in html format
#        --with-sublime               open file by sublime in html format (requires subl-handler)
#        --with-mvim                  open file by mvim in html format
#        --with-github GITHUB_NAME    open file on github in html format, GITHUB_NAME is like railsbp/rails-bestpractices.com
#        --with-git                   display git commit and username, only support html format
#        --with-hg                    display hg commit and username, only support html format
#        --template TEMPLATE          customize erb template
#        --vendor                     include vendor files
#        --spec                       include spec files
#        --test                       include test files
#        --features                   include features files
#    -x, --exclude PATTERNS           don't analyze files matching a pattern
#                                     (comma-separated regexp list)
#    -o, --only PATTERNS              analyze files only matching a pattern
#                                     (comma-separated regexp list)
#    -g, --generate                   generate configuration yaml
#    -v, --version                    show this version
#    -h, --help                       show this message

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: rails_best_practices [options] path"

  opts.on("-d", "--debug", "Debug mode") do
    options["debug"] = true
  end

  opts.on("-f", "--format FORMAT", "output format (text, html, yml, json, xml)") do |format|
    options["format"] = format
  end

  opts.on("--without-color", "only output plain text without color") do
    options["without-color"] = true
  end

  opts.on("--with-textmate", "open file by textmate in html format") do
    options["with-textmate"] = true
  end

  opts.on("--with-sublime", "open file by sublime in html format") do
    options["with-sublime"] = true
  end

  opts.on("--with-mvim", "open file by mvim in html format") do
    options["with-mvim"] = true
  end

  opts.on("--with-github GITHUB_NAME", "open file on github in html format") do |github_name|
    options["with-github"] = true
    options["github-name"] = github_name
  end

  opts.on("--last-commit-id COMMIT_ID", "last commit id") do |commit_id|
    options["last-commit-id"] = commit_id
  end

  opts.on("--with-hg", "display hg commit and username, only support html format") do
    options["with-hg"] = true
  end

  opts.on("--with-git", "display git commit and username, only support html format") do
    options["with-git"] = true
  end

  opts.on("--template TEMPLATE", "customize erb template") do |template|
    options["template"] = template
  end

  opts.on("--output-file OUTPUT_FILE", "output html file for the analyzing result") do |output_file|
    options["output-file"] = output_file
  end

  opts.on("--silent", "silent mode") do
    options["silent"] = true
  end

  ["vendor", "spec", "test", "features"].each do |pattern|
    opts.on("--#{pattern}", "include #{pattern} files") do
      options[pattern] = true
    end
  end

  opts.on_tail("-v", "--version", "Show this version") do
    require "rails_best_practices/version"
    puts RailsBestPractices::VERSION
    exit
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.on("-x", "--exclude PATTERNS", "Don't analyze files matching a pattern", "(comma-separated regexp list)") do |list|
    begin
      options["exclude"] = list.split(",").map{|x| Regexp.new x}
    rescue RegexpError => e
      raise OptionParser::InvalidArgument, e.message
    end
  end

  opts.on("-o", "--only PATTERNS", "Analyze files only matching a pattern", "(comma-separated regexp list)") do |list|
    begin
      options["only"] = list.split(",").map { |x| Regexp.new x }
    rescue RegexpError => e
      raise OptionParser::InvalidArgument e.message
    end
  end

  opts.on("-g", "--generate", "Generate configuration yaml") do
    options["generate"] = true
  end

  opts.on(
    '-c',
    '--config CONFIG_PATH', 'configuration file location (defaults to config/rails_best_practices.yml)'
  ) do |config_path|
    options['config'] = config_path
  end

  opts.parse!
end

if ARGV.size > 0 && !File.exists?(ARGV.first)
  puts "#{ARGV.first} doesn't exist"
  exit 1
end

if options["generate"]
  RailsBestPractices::Analyzer.new(ARGV.first).generate
else
  analyzer = RailsBestPractices::Analyzer.new(ARGV.first, options)
  analyzer.analyze
  analyzer.output
  exit analyzer.runner.errors.size > 0 ? 1 : 0
end
