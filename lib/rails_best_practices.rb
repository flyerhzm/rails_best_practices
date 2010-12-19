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
require 'progressbar'
require 'colored'
require 'rails_best_practices/checks'
require 'rails_best_practices/core'

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
  class <<self
    attr_writer :runner
    # start checking rails codes.
    #
    # there are two steps to check rails codes,
    #
    # 1. prepare process, check all model and mailer files.
    # 2. review process, check all files.
    #
    # if there are violations to rails best practices, output them.
    #
    # path is the root directory of rails project.
    # options can be debug, exclude and so on,
    #         see more info in command.rb.
    def start(path, options)
      @path = path || '.'
      @runner = Core::Runner.new
      @runner.debug = true if options['debug']

      if @runner.checks.find { |check| check.is_a? Checks::AlwaysAddDbIndexCheck } &&
         !review_files.find { |file| file.index "db\/schema.rb" }
        puts "AlwaysAddDbIndexCheck is disabled as there is no db/schema.rb file in your rails project.".blue
      end

      @bar = ProgressBar.new('Analyzing', prepare_files.size + review_files.size)
      process("prepare", options)
      process("review", options)
      @bar.finish

      output_errors
      exit @runner.errors.size
    end

    # process prepare or reivew.
    #
    # get all files for the process, analyze each file,
    # and increment progress bar unless debug.
    #
    # process is the process name, prepare or review.
    # options is the command options.
    def process(process, options)
      files = send("#{process}_files", @path, options)
      files.each do |file|
        @runner.send("#{process}_file", file)
        @bar.inc unless @runner.debug
      end
    end

    # return all files for prepare process.
    def prepare_files(dir = '.', options = {})
      files = []
      ['models', 'mailers'].each do |name|
        files += expand_dirs_to_files(File.join(dir, 'app', name))
      end
      files
    end

    # return all files for review process.
    def review_files(dir = '.', options = {})
      files = expand_dirs_to_files(dir)
      files = file_sort(files)
      ['vendor', 'spec', 'test', 'features'].each do |pattern|
        files = file_ignore(files, "#{pattern}/") unless options[pattern]
      end

      # Exclude files based on exclude regexes if the option is set.
      for pattern in options[:exclude]
        files = file_ignore(files, pattern)
      end

      files
    end

    # expand all files with extenstion rb, erb, haml and builder under the dirs
    def expand_dirs_to_files *dirs
      extensions = ['rb', 'erb', 'haml', 'builder']

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
    def file_sort files
      files.sort { |a, b|
        if a =~ Checks::Check::MODEL_FILES
          -1
        elsif b =~ Checks::Check::MODEL_FILES
          1
        elsif a =~ Checks::Check::MAILER_FILES
          -1
        elsif b =~ Checks::Check::MAILER_FILES
          1
        else
          a <=> b
        end
      }
    end

    # ignore specific files.
    def file_ignore files, pattern
      files.reject { |file| file.index(pattern) }
    end

    # output errors if exist.
    def output_errors
      @runner.errors.each { |error| puts error.to_s.red }
      puts "\nPlease go to http://rails-bestpractices.com to see more useful Rails Best Practices.".green
      if @runner.errors.empty?
        puts "\nNo error found. Cool!".green
      else
        puts "\nFound #{@runner.errors.size} errors.".red
      end
    end
  end
end
