require 'rails_best_practices/checks'
require 'rails_best_practices/core'

module RailsBestPractices
  
  class <<self
    def analyze_files(dir = '.', options = {})
      files = expand_dirs_to_files(dir)
      files = model_first_sort(files)
      ['vendor', 'spec', 'test', 'stories', 'features'].each do |pattern|
        files = ignore_files(files, "#{pattern}/") unless options[pattern]
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
