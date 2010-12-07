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

require 'rails_best_practices/checks'
require 'rails_best_practices/core'

module RailsBestPractices

  class <<self
    def prepare_files
      expand_dirs_to_files 'app/models'
    end

    def analyze_files(dir = '.', options = {})
      files = expand_dirs_to_files(dir)
      files = model_first_sort(files)
      ['vendor', 'spec', 'test', 'stories', 'features'].each do |pattern|
        files = ignore_files(files, "#{pattern}/") unless options[pattern]
      end

      # Exclude files based on exclude regexes if the option is set.
      for pattern in options[:exclude]
        files = ignore_files(files, pattern)
      end

      files
    end

    def expand_dirs_to_files *dirs
      extensions = ['rb', 'erb', 'haml', 'builder']

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

    def ignore_files files, pattern
      files.reject { |file| file.index(pattern) }
    end
  end
end
