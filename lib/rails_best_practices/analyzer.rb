# encoding: utf-8
require 'fileutils'

require 'progressbar'
require 'colored'

module RailsBestPractices
  # RailsBestPractices Analyzer helps you to analyze your rails code, according to best practices on http://rails-bestpractices.
  # if it finds any violatioins to best practices, it will give you some readable suggestions.
  #
  # The analysis process is partitioned into two parts,
  #
  # 1. prepare process, it checks only model and mailer files, do some preparations, such as remember model names and associations.
  # 2. review process, it checks all files, according to configuration, it really check if codes violate the best practices, if so, remember the violations.
  #
  # After analyzing, output the violations.
  class Analyzer
    attr_accessor :runner

    DEFAULT_CONFIG = File.join(File.dirname(__FILE__), "..", "..", "rails_best_practices.yml")

    # initialize
    #
    # @param [String] path where to generate the configuration yaml file
    # @param [Hash] options
    def initialize(path, options={})
      @path = path || "."
      @options = options
    end

    # generate configuration yaml file.
    def generate
      FileUtils.cp DEFAULT_CONFIG, File.join(@path, 'config/rails_best_practices.yml')
    end

    # Analyze rails codes.
    #
    # there are two steps to check rails codes,
    #
    # 1. prepare process, check all model and mailer files.
    # 2. review process, check all files.
    #
    # if there are violations to rails best practices, output them.
    #
    # @param [String] path the directory of rails project
    # @param [Hash] options
    def analyze
      @options["exclude"] ||= []
      @options["output-file"] ||= "rails_best_practices_output.html"

      Core::Runner.base_path = @path
      @runner = Core::Runner.new
      @runner.debug = true if @options["debug"]
      @runner.color = !@options["without-color"]

      @bar = ProgressBar.new('Source Codes', parse_files.size * 3) if display_bar?
      ["lexical", "prepare", "review"].each { |process| send(:process, process) }
      @runner.on_complete
      @bar.finish if display_bar?
    end

    def display_bar?
      !@options["debug"] && !@options["silent"]
    end

    # Output the analyze result.
    def output
      if @options["format"] == 'html'
        if @options["with-hg"]
          load_hg_info
        elsif @options["with-git"]
          load_git_info
        end
        output_html_errors
      else
        output_terminal_errors
      end
    end

    # process lexical, prepare or reivew.
    #
    # get all files for the process, analyze each file,
    # and increment progress bar unless debug.
    #
    # @param [String] process the process name, lexical, prepare or review.
    def process(process)
      parse_files.each do |file|
        @runner.send("#{process}_file", file)
        @bar.inc if display_bar?
      end
    end

    # get all files for parsing.
    #
    # @return [Array] all files for parsing
    def parse_files
      @parse_files ||= begin
        files = expand_dirs_to_files(@path)
        files = file_sort(files)

        # By default, tmp, vender, spec, test, features are ignored.
        ["vendor", "spec", "test", "features", "tmp"].each do |pattern|
          files = file_ignore(files, "#{pattern}/") unless @options[pattern]
        end

        # Exclude files based on exclude regexes if the option is set.
        @options["exclude"].each do |pattern|
          files = file_ignore(files, pattern)
        end

        files.compact
      end
    end

    # expand all files with extenstion rb, erb, haml and builder under the dirs
    #
    # @param [Array] dirs what directories to expand
    # @return [Array] all files expanded
    def expand_dirs_to_files *dirs
      extensions = ['rb', 'erb', 'rake', 'rhtml', 'haml', 'builder']

      dirs.flatten.map { |entry|
        next unless File.exist? entry
        if File.directory? entry
          Dir[File.join(entry, '**', "*.{#{extensions.join(',')}}")]
        else
          entry
        end
      }.flatten
    end


    # sort files, models first, then mailers, and sort other files by characters.
    #
    # models and mailers first as for prepare process.
    #
    # @param [Array] files
    # @return [Array] sorted files
    def file_sort files
      models = []
      mailers = []
      files.each do |a|
        if a =~ Core::Check::MODEL_FILES
          models << a
        end
      end
      files.each do |a|
        if a =~ Core::Check::MAILER_FILES
          mailers << a
        end
      end
      files.collect! do |a|
        if a =~ Core::Check::MAILER_FILES || a =~ Core::Check::MODEL_FILES
          #nil
        else
          a
        end
      end
      files.compact!
      models.sort
      mailers.sort
      files.sort
      return models + mailers + files
    end

    # ignore specific files.
    #
    # @param [Array] files
    # @param [Regexp] pattern files match the pattern will be ignored
    # @return [Array] files that not match the pattern
    def file_ignore files, pattern
      files.reject { |file| file.index(pattern) }
    end

    # output errors on terminal.
    def output_terminal_errors
      @runner.errors.each { |error| plain_output(error.to_s, 'red') }
      plain_output("\nPlease go to http://rails-bestpractices.com to see more useful Rails Best Practices.", 'green')
      if @runner.errors.empty?
        plain_output("\nNo warning found. Cool!", 'green')
      else
        plain_output("\nFound #{@runner.errors.size} warnings.", 'red')
      end
    end

    # load hg commit and hg username info.
    def load_hg_info
      hg_progressbar = ProgressBar.new('Hg Info', @runner.errors.size) if display_bar?
      @runner.errors.each do |error|
        hg_info = `cd #{@runner.class.base_path}; hg blame -lvcu #{error.filename[@runner.class.base_path.size..-1].gsub(/^\//, "")} | sed -n /:#{error.line_number.split(',').first}:/p`
        unless hg_info == ""
          hg_commit_username = hg_info.split(':')[0].strip
          error.hg_username = hg_commit_username.split(/\ /)[0..-2].join(' ')
          error.hg_commit = hg_commit_username.split(/\ /)[-1]
        end
        hg_progressbar.inc if display_bar?
      end
      hg_progressbar.finish if display_bar?
    end

    # load git commit and git username info.
    def load_git_info
      git_progressbar = ProgressBar.new('Git Info', @runner.errors.size) if display_bar?
      @runner.errors.each do |error|
        git_info = `cd #{@runner.class.base_path}; git blame #{error.filename[@runner.class.base_path.size..-1]} | sed -n #{error.line_number.split(',').first}p`
        unless git_info == ""
          git_commit, git_username = git_info.split(/\d{4}-\d{2}-\d{2}/).first.split("(")
          error.git_commit = git_commit.split(" ").first.strip
          error.git_username = git_username.strip
        end
        git_progressbar.inc if display_bar?
      end
      git_progressbar.finish if display_bar?
    end

    # output errors with html format.
    def output_html_errors
      require 'erubis'
      table_template = File.read(File.join(File.dirname(__FILE__), "..", "..", "assets", "table.html.erb"))
      result_template = File.read(File.join(File.dirname(__FILE__), "..", "..", "assets", "result.html.erb"))

      if @options["with-github"]
        last_commit_id = @options["last-commit-id"] ? @options["last-commit-id"] : `cd #{@runner.class.base_path}; git rev-parse HEAD`.chomp
      end
      File.open(@options["output-file"], "w+") do |file|
        table_eruby = Erubis::Eruby.new(table_template)
        result_eruby = Erubis::Eruby.new(result_template)
        result_table = table_eruby.evaluate(
          :errors => @runner.errors,
          :textmate => @options["with-textmate"],
          :mvim => @options["with-mvim"],
          :github => @options["with-github"],
          :github_name => @options["github-name"],
          :last_commit_id => last_commit_id,
          :git => @options["with-git"],
          :hg => @options["with-hg"]
        )
        if @options["only-table"]
          file.puts result_table
        else
          file.puts result_eruby.evaluate(
            :errors => @runner.errors,
            :error_types => error_types,
            :result_table => result_table
          )
        end
      end
    end

    # plain output with color.
    #
    # @param [String] message to output
    # @param [String] color
    def plain_output(message, color)
      if @options["without-color"]
        puts message
      else
        puts message.send(color)
      end
    end

    # unique error types.
    def error_types
      @runner.errors.map(&:type).uniq
    end
  end
end
