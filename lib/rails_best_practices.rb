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
require 'haml'
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
      Core::Runner.base_path = @path
      @runner = Core::Runner.new
      @runner.debug = true if @options['debug']
      @runner.color = !options['without-color']

      if @runner.checks.find { |check| check.is_a? Reviews::AlwaysAddDbIndexReview } &&
         !review_files.find { |file| file.index "db\/schema.rb" }
        plain_output("AlwaysAddDbIndexReview is disabled as there is no db/schema.rb file in your rails project.", 'blue')
      end

      @bar = ProgressBar.new('Analyzing', prepare_files.size + review_files.size)
      process("prepare")
      process("review")
      @bar.finish

      if @options['format'] == 'html'
        output_html_errors
      else
        output_terminal_errors
      end
      exit @runner.errors.size
    end

    # process prepare or reivew.
    #
    # get all files for the process, analyze each file,
    # and increment progress bar unless debug.
    #
    # @param [String] process the process name, prepare or review.
    def process(process)
      files = send("#{process}_files")
      files.each do |file|
        @runner.send("#{process}_file", file)
        @bar.inc unless @options['debug']
      end
    end

    # get all files for prepare process.
    #
    # @return [Array] all files for prepare process
    def prepare_files
      @prepare_files ||= begin
        ['models', 'mailers'].inject([]) { |files, name|
          files += expand_dirs_to_files(File.join(@path, 'app', name))
        }.compact
      end
    end

    # get all files for review process.
    #
    # @return [Array] all files for review process
    def review_files
      @review_files ||= begin
        files = expand_dirs_to_files(@path)
        files = file_sort(files)
        ['vendor', 'spec', 'test', 'features'].each do |pattern|
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
      extensions = ['rb', 'erb', 'rhtml', 'haml', 'builder']

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
      files.sort { |a, b|
        if a =~ Core::Check::MODEL_FILES
          -1
        elsif b =~ Core::Check::MODEL_FILES
          1
        elsif a =~ Core::Check::MAILER_FILES
          -1
        elsif b =~ Core::Check::MAILER_FILES
          1
        else
          a <=> b
        end
      }
    end

    # ignore specific files.
    #
    # @param [Array] files
    # @param [Regexp] pattern files match the pattern will be ignored
    # @return [Array] files that not match the pattern
    def file_ignore files, pattern
      files.reject { |file| file.index(pattern) }
    end

    # output errors if exist.
    def output_terminal_errors
      @runner.errors.each { |error| plain_output(error.to_s, 'red') }
      plain_output("\nPlease go to http://rails-bestpractices.com to see more useful Rails Best Practices.", 'green')
      if @runner.errors.empty?
        plain_output("\nNo error found. Cool!", 'green')
      else
        plain_output("\nFound #{@runner.errors.size} errors.", 'red')
      end
    end

    def plain_output(message, color)
      if @options["without-color"]
        puts message
      else
        puts message.send(color)
      end
    end

    def output_html_errors
      template = File.read(File.join(File.dirname(__FILE__), "..", "assets", "result.html.haml"))

      File.open("rails_best_practices_output.html", "w+") do |file|
        file.puts Haml::Engine.new(template).render(Object.new, :errors => @runner.errors, :textmate => @options["with-textmate"])
      end
    end
  end
end
