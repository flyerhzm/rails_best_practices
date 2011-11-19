# encoding: utf-8

#--
# Copyright (c) 2010 Richard Huang (flyerhzm@gmail.com)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
require 'rubygems'
require 'progressbar'
require 'colored'
require 'rails_best_practices/lexicals'
require 'rails_best_practices/prepares'
require 'rails_best_practices/reviews'
require 'rails_best_practices/core'
require 'fileutils'

# RailsBestPractices helps you to analyze your rails code, according to best practices on http://rails-bestpractices.
# if it finds any violatioins to best practices, it will give you some readable suggestions.
#
# The analysis process is partitioned into two parts,
#
# 1. prepare process, it checks only model and mailer files, do some preparations, such as remember model names and associations.
# 2. review process, it checks all files, according to configuration, it really check if codes violate the best practices, if so, remember the violations.
#
# After analyzing, output the violations.
module RailsBestPractices

  DEFAULT_CONFIG = File.join(File.dirname(__FILE__), "..", "rails_best_practices.yml")

  class <<self
    attr_writer :runner

    # generate configuration yaml file.
    #
    # @param [String] path where to generate the configuration yaml file
    def generate(path)
      @path =  path || '.'
      FileUtils.cp DEFAULT_CONFIG, File.join(@path, 'config/rails_best_practices.yml')
    end

    # start checking rails codes.
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
    def start(path, options)
      @path = path || '.'
      @options = options
      @options[:exclude] ||= []

      Core::Runner.base_path = @path
      @runner = Core::Runner.new
      @runner.debug = true if @options['debug']
      @runner.color = !options['without-color']

      if @runner.checks.find { |check| check.is_a? Reviews::AlwaysAddDbIndexReview } &&
         !parse_files.find { |file| file.index "db\/schema.rb" }
        plain_output("AlwaysAddDbIndexReview is disabled as there is no db/schema.rb file in your rails project.", 'blue')
      end

      @bar = ProgressBar.new('Source Codes', parse_files.size * 3)
      ["lexical", "prepare", "review"].each { |process| send(:process, process) }
      @runner.on_complete
      @bar.finish

      if @options['format'] == 'html'
        load_git_info if @options["with-git"]
        output_html_errors
      else
        output_terminal_errors
      end
      exit @runner.errors.size
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
        @bar.inc unless @options['debug']
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
        ['vendor', 'spec', 'test', 'features', 'tmp'].each do |pattern|
          files = file_ignore(files, "#{pattern}/") unless @options[pattern]
        end

        # Exclude files based on exclude regexes if the option is set.
        @options[:exclude].each do |pattern|
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

    # load git commit and git username info.
    def load_git_info
      git_progressbar = ProgressBar.new('Git Info', @runner.errors.size)
      @runner.errors.each do |error|
        git_info = `cd #{@runner.class.base_path}; git blame #{error.filename[@runner.class.base_path.size..-1]} | sed -n #{error.line_number.split(',').first}p`
        unless git_info == ""
          git_commit, git_username = git_info.split(/\d{4}-\d{2}-\d{2}/).first.split("(")
          error.git_commit = git_commit.split(" ").first.strip
          error.git_username = git_username.strip
        end
        git_progressbar.inc unless @options['debug']
      end
      git_progressbar.finish
    end

    # output errors with html format.
    def output_html_errors
      require 'erubis'
      template = File.read(File.join(File.dirname(__FILE__), "..", "assets", "result.html.erb"))

      File.open("rails_best_practices_output.html", "w+") do |file|
        eruby = Erubis::Eruby.new(template)
        file.puts eruby.evaluate(:errors => @runner.errors, :error_types => error_types, :textmate => @options["with-textmate"], :mvim => @options["with-mvim"], :git => @options["with-git"])
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
