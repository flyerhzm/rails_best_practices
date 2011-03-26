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
      attr_accessor :debug, :whiny, :color

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

      # initialize the runner.
      #
      # @param [Hash] options pass the prepares and reviews.
      def initialize(options={})
        custom_config = File.join(Runner.base_path, 'config/rails_best_practices.yml')
        @config = File.exists?(custom_config) ? custom_config : RailsBestPractices::DEFAULT_CONFIG

        prepares = Array(options[:prepares])
        reviews = Array(options[:reviews])
        @lexicals = load_lexicals
        @prepares = prepares.empty? ? load_prepares : prepares
        @reviews = reviews.empty? ? load_reviews : reviews

        load_plugin_reviews if reviews.empty?

        @checker ||= CheckingVisitor.new(:prepares => @prepares, :reviews => @reviews, :lexicals => @lexicals)
        @debug = false
        @whiny = false
      end

      # lexical analysis the file.
      #
      # @param [String] filename name of the file
      # @param [String] content content of the file
      def lexical(filename, content)
        puts filename if @debug
        @checker.lexical(filename, content)
      end

      # lexical analysis the file.
      #
      # @param [String] filename
      def lexical_file(filename)
        lexical(filename, File.open(filename, "r:UTF-8") { |f| f.read })
      end

      # prepare and review a file's content with filename.
      # the file may be a ruby, erb or haml file.
      #
      # filename is the filename of the code.
      # content is the source code.
      [:prepare, :review].each do |process|
        class_eval <<-EOS
          def #{process}(filename, content)                                        # def review(filename, content)
            puts filename if @debug                                                #   puts filename if @debug
            content = parse_erb_or_haml(filename, content)                         #   content = parse_erb_or_haml(filename, content)
            node = parse_ruby(filename, content)                                   #   node = parse_ruby(filename, content)
            node.#{process}(@checker) if node                                      #   node.review(@checker) if node
          end                                                                      # end
                                                                                   #
          def #{process}_file(filename)                                            # def review_file(filename)
            #{process}(filename, File.open(filename, "r:UTF-8") { |f| f.read })    #   review(filename, File.open(filename, "r:UTF-8") { |f| f.read })
          end                                                                      # end
        EOS
      end

      # get all errors from lexicals and reviews.
      #
      # @return [Array] all errors from lexicals and reviews
      def errors
        (@reviews + @lexicals).collect {|check| check.errors}.flatten
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
            if @debug
              warning = "#{filename} looks like it's not a valid Ruby file.  Skipping..."
              warning = warning.red if self.color
              puts warning
            end
            raise e if @whiny
            nil
          end
        end

        # parse erb or html code.
        #
        # filename is the filename of the erb or haml code.
        # content is the source code of erb or haml file.
        def parse_erb_or_haml(filename, content)
          if filename =~ /.*\.erb|.*\.rhtml$/
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

        # load all lexical checks.
        def load_lexicals
          checks_from_config.inject([]) { |active_checks, check|
            begin
              check_name, options = *check
              klass = RailsBestPractices::Lexicals.const_get(check_name)
              active_checks << (options.empty? ? klass.new : klass.new(options))
            rescue
              # the check does not exist in the Lexicals namepace.
            end
            active_checks
          }
        end

        # load all prepares.
        def load_prepares
          [Prepares::ModelPrepare.new, Prepares::MailerPrepare.new, Prepares::SchemaPrepare.new]
        end

        # load all reviews according to configuration.
        def load_reviews
          checks_from_config.inject([]) { |active_checks, check|
            begin
              check_name, options = *check
              klass = RailsBestPractices::Reviews.const_get(check_name.gsub(/Check/, 'Review'))
              active_checks << (options.empty? ? klass.new : klass.new(options))
            rescue
              # the check does not exist in the Reviews namepace.
            end
            active_checks
          }
        end

        # load all plugin reviews.
        def load_plugin_reviews
          begin
            plugins = "lib/rails_best_practices/plugins/reviews"
            if File.directory?(plugins)
              Dir[File.expand_path(File.join(plugins, "*.rb"))].each do |review|
                require review
              end
              RailsBestPractices::Plugins::Reviews.constants.each do |review|
                @reviews << RailsBestPractices::Plugins::Reviews.const_get(review).new
              end
            end
          end
        end

        # read the checks from yaml config.
        def checks_from_config
          @checks ||= YAML.load_file @config
        end
    end
  end
end
