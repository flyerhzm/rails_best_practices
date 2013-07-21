# encoding: utf-8
require 'ap'
require 'colored'
require 'fileutils'
require 'ruby-progressbar'

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
    attr_reader :path

    DEFAULT_CONFIG = File.join(File.dirname(__FILE__), "..", "..", "rails_best_practices.yml")
    GITHUB_URL = 'https://github.com/'

    # initialize
    #
    # @param [String] path where to generate the configuration yaml file
    # @param [Hash] options
    def initialize(path, options={})
      @path = File.expand_path(path || ".")

      @options = options
      @options["exclude"] ||= []
      @options["only"] ||= []
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
      Core::Runner.base_path = @path
      @runner = Core::Runner.new

      analyze_source_codes
      analyze_vcs
    end

    # Output the analyze result.
    def output
      if @options["format"] == 'html'
        @options["output-file"] ||= "rails_best_practices_output.html"
        output_html_errors
      elsif @options["format"] == 'yaml'
        @options["output-file"] ||= "rails_best_practices_output.yaml"
        output_yaml_errors
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
        begin
          puts file if @options["debug"]
          @runner.send(process, file, File.read(file))
        rescue
          if @options["debug"]
            warning = "#{file} looks like it's not a valid Ruby file.  Skipping..."
            plain_output(warning, 'red')
          end
        end
        @bar.increment if display_bar?
      end
      @runner.send("after_#{process}")
    end

    # get all files for parsing.
    #
    # @return [Array] all files for parsing
    def parse_files
      @parse_files ||= begin
        files = expand_dirs_to_files(@path)
        files = file_sort(files)

        if @options["only"].present?
          files = file_accept(files, @options["only"])
        end

        # By default, tmp, vender, spec, test, features are ignored.
        ["vendor", "spec", "test", "features", "tmp"].each do |dir|
          files = file_ignore(files, File.join(@path, dir)) unless @options[dir]
        end

        # Exclude files based on exclude regexes if the option is set.
        @options["exclude"].each do |pattern|
          files = file_ignore(files, pattern)
        end

        %w(Capfile Gemfile Gemfile.lock).each do |file|
          files.unshift File.join(@path, file)
        end

        files.compact
      end
    end

    # expand all files with extenstion rb, erb, haml, slim, builder and rxml under the dirs
    #
    # @param [Array] dirs what directories to expand
    # @return [Array] all files expanded
    def expand_dirs_to_files(*dirs)
      extensions = ['rb', 'erb', 'rake', 'rhtml', 'haml', 'slim', 'builder', 'rxml', 'rabl']

      dirs.flatten.map { |entry|
        next unless File.exist? entry
        if File.directory? entry
          Dir[File.join(entry, '**', "*.{#{extensions.join(',')}}")]
        else
          entry
        end
      }.flatten
    end


    # sort files, models first, mailers, helpers, and then sort other files by characters.
    #
    # models and mailers first as for prepare process.
    #
    # @param [Array] files
    # @return [Array] sorted files
    def file_sort(files)
      models = files.find_all { |file| file =~ Core::Check::MODEL_FILES }
      mailers = files.find_all { |file| file =~ Core::Check::MAILER_FILES }
      helpers = files.find_all { |file| file =~ Core::Check::HELPER_FILES }
      others = files.find_all { |file| file !~ Core::Check::MAILER_FILES && file !~ Core::Check::MODEL_FILES && file !~ Core::Check::HELPER_FILES }
      return models + mailers + helpers + others
    end

    # ignore specific files.
    #
    # @param [Array] files
    # @param [Regexp] pattern files match the pattern will be ignored
    # @return [Array] files that not match the pattern
    def file_ignore(files, pattern)
      files.reject { |file| file.index(pattern) }
    end

    # accept specific files.
    #
    # @param [Array] files
    # @param [Regexp] patterns, files match any pattern will be accepted
    def file_accept(files, patterns)
      files.reject { |file| !patterns.any? { |pattern| file =~ pattern } }
    end

    # output errors on terminal.
    def output_terminal_errors
      errors.each { |error| plain_output(error.to_s, 'red') }
      plain_output("\nPlease go to http://rails-bestpractices.com to see more useful Rails Best Practices.", 'green')
      if errors.empty?
        plain_output("\nNo warning found. Cool!", 'green')
      else
        plain_output("\nFound #{errors.size} warnings.", 'red')
      end
    end

    # load hg commit and hg username info.
    def load_hg_info
      hg_progressbar = ProgressBar.create(:title => 'Hg Info', :total => errors.size) if display_bar?
      errors.each do |error|
        hg_info = `cd #{@runner.class.base_path} && hg blame -lvcu #{error.filename[@runner.class.base_path.size..-1].gsub(/^\//, "")} | sed -n /:#{error.line_number.split(',').first}:/p`
        unless hg_info == ""
          hg_commit_username = hg_info.split(':')[0].strip
          error.hg_username = hg_commit_username.split(/\ /)[0..-2].join(' ')
          error.hg_commit = hg_commit_username.split(/\ /)[-1]
        end
        hg_progressbar.increment if display_bar?
      end
      hg_progressbar.finish if display_bar?
    end

    # load git commit and git username info.
    def load_git_info
      git_progressbar = ProgressBar.create(:title => 'Git Info', :total => errors.size) if display_bar?
      start = @runner.class.base_path =~ /\/$/ ? @runner.class.base_path.size : @runner.class.base_path.size + 1
      errors.each do |error|
        git_info = `cd #{@runner.class.base_path} && git blame -L #{error.line_number.split(',').first},+1 #{error.filename[start..-1]}`
        unless git_info == ""
          git_commit, git_username = git_info.split(/\d{4}-\d{2}-\d{2}/).first.split("(")
          error.git_commit = git_commit.split(" ").first.strip
          error.git_username = git_username.strip
        end
        git_progressbar.increment if display_bar?
      end
      git_progressbar.finish if display_bar?
    end

    # output errors with html format.
    def output_html_errors
      require 'erubis'
      template = @options["template"] ? File.read(File.expand_path(@options["template"])) : File.read(File.join(File.dirname(__FILE__), "..", "..", "assets", "result.html.erb"))

      if @options["with-github"]
        last_commit_id = @options["last-commit-id"] ? @options["last-commit-id"] : `cd #{@runner.class.base_path} && git rev-parse HEAD`.chomp
        unless @options["github-name"].start_with?('http')
          @options["github-name"] = GITHUB_URL + @options["github-name"]
        end
      end
      File.open(@options["output-file"], "w+") do |file|
        eruby = Erubis::Eruby.new(template)
        file.puts eruby.evaluate(
          errors: errors,
          error_types: error_types,
          textmate: @options["with-textmate"],
          sublime: @options["with-sublime"],
          mvim: @options["with-mvim"],
          github: @options["with-github"],
          github_name: @options["github-name"],
          last_commit_id: last_commit_id,
          git: @options["with-git"],
          hg: @options["with-hg"]
        )
      end
    end

    # output errors with yaml format.
    def output_yaml_errors
      File.open(@options["output-file"], "w+") do |file|
        file.write YAML.dump(errors)
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

    # analyze source codes.
    def analyze_source_codes
      @bar = ProgressBar.create(:title => 'Source Codes', :total => parse_files.size * 3) if display_bar?
      ["lexical", "prepare", "review"].each { |process| send(:process, process) }
      @bar.finish if display_bar?
    end

    # analyze version control system info.
    def analyze_vcs
      load_git_info if @options["with-git"]
      load_hg_info if @options["with-hg"]
    end

    # if disaply progress bar.
    def display_bar?
      !@options["debug"] && !@options["silent"]
    end

    # unique error types.
    def error_types
      errors.map(&:type).uniq
    end

    # delegate errors to runner
    def errors
      @runner.errors
    end
  end
end
