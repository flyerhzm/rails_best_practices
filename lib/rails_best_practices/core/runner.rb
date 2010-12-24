# encoding: utf-8
require 'rubygems'
require 'ruby_parser'
require 'erubis'
require 'yaml'
require 'active_support/inflector'

module RailsBestPractices
  module Core
    # Runner is the main class, it can check source code of a filename with all checks (according to the configuration).
    #
    # the check process is partitioned into two parts,
    #
    # 1. prepare process, it will do some preparations for further checking, such as remember the model associations.
    # 2. review process, it does real check, if the source code violates some best practices, the violations will be notified.
    class Runner
      attr_reader :checks
      attr_accessor :debug

      # set the base path.
      #
      # @param [String] path the base path
      def self.base_path=(path)
        @base_path = path
      end

      # get the base path, by default, the base path is current path.
      #
      # @return [String] the base path
      def self.base_path
        @base_path || "."
      end

      def initialize(*checks)
        custom_config = File.join(Runner.base_path, 'config/rails_best_practices.yml')
        @config = File.exists?(custom_config) ? custom_config : RailsBestPractices::DEFAULT_CONFIG
        @checks = checks unless checks.empty?
        @checks ||= load_checks
        @checker ||= CheckingVisitor.new(@checks)
        @debug = false
      end

      # prepare and review a file's content with filename.
      # the file may be a ruby, erb or haml file.
      #
      # filename is the filename of the code.
      # content is the source code.
      [:prepare, :review].each do |process|
        class_eval <<-EOS
          def #{process}(filename, content)                      # def review(filename, content)
            puts filename if @debug                              #   puts filename if @debug
            content = parse_erb_or_haml(filename, content)       #   content = parse_erb_or_haml(filename, content)
            node = parse_ruby(filename, content)                 #   node = parse_ruby(filename, content)
            node.#{process}(@checker) if node                    #   node.review(@checker) if node
          end                                                    # end
                                                                 #
          def #{process}_file(filename)                          # def review_file(filename)
            #{process}(filename, File.read(filename))            #   review(filename, File.read(filename))
          end                                                    # end
        EOS
      end

      # get all errors from checks.
      #
      # @return [Array] all errors from checks
      def errors
        @checks ||= []
        all_errors = @checks.collect {|check| check.errors}
        all_errors.flatten
      end

      private
        # parse ruby code.
        #
        # filename is the filename of the ruby code.
        # content is the source code of ruby file.
        def parse_ruby(filename, content)
          begin
            RubyParser.new.parse(content, filename)
          rescue Exception => e
            puts "#{filename} looks like it's not a valid Ruby file.  Skipping...".red if @debug
            nil
          end
        end

        # parse erb or html code.
        #
        # filename is the filename of the erb or haml code.
        # content is the source code of erb or haml file.
        def parse_erb_or_haml(filename, content)
          if filename =~ /.*\.erb$/
            content = Erubis::Eruby.new(content).src
          elsif filename =~ /.*\.haml$/
            begin
              require 'haml'
              content = Haml::Engine.new(content).precompiled
              # remove \xxx characters
              content.gsub!(/\\\d{3}/, '')
            rescue Haml::SyntaxError
            end
          end
          content
        end

        # load all checks according to configuration.
        def load_checks
          check_objects = []
          checks = YAML.load_file @config
          checks.each do |check|
            klass = RailsBestPractices::Checks.const_get(check[0])
            check_objects << (check[1].empty? ? klass.new : klass.new(check[1]))
          end
          check_objects
        end
    end
  end
end
