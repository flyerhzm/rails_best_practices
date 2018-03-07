# encoding: utf-8
require 'yaml'
require 'active_support/core_ext/object/blank'
begin
  require 'active_support/core_ext/object/try'
rescue LoadError
  require 'active_support/core_ext/try'
end
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
        @base_path || '.'
      end

      # set the configuration path
      #
      # @param path [String] path to rbc config file
      def self.config_path=(path)
        @config_path = path
      end

      # get the configuration path, if will default to config/rails_best_practices.yml
      #
      # @return [String] the config path
      def self.config_path
        custom_config = @config_path || File.join(Runner.base_path, 'config/rails_best_practices.yml')
        File.exists?(custom_config) ? custom_config : RailsBestPractices::Analyzer::DEFAULT_CONFIG
      end

      # initialize the runner.
      #
      # @param [Hash] options pass the prepares and reviews.
      def initialize(options = {})
        @config = self.class.config_path

        lexicals = Array(options[:lexicals])
        prepares = Array(options[:prepares])
        reviews = Array(options[:reviews])

        checks_loader = ChecksLoader.new(@config)
        @lexicals = lexicals.empty? ? checks_loader.load_lexicals : lexicals
        @prepares = prepares.empty? ? load_prepares : prepares
        @reviews = reviews.empty? ? checks_loader.load_reviews : reviews
        load_plugin_reviews if reviews.empty?

        @lexical_checker ||= CodeAnalyzer::CheckingVisitor::Plain.new(checkers: @lexicals)
        @plain_prepare_checker ||= CodeAnalyzer::CheckingVisitor::Plain.new(checkers: @prepares.select { |checker| checker.is_a? Prepares::GemfilePrepare })
        @default_prepare_checker ||= CodeAnalyzer::CheckingVisitor::Default.new(checkers: @prepares.select { |checker| !checker.is_a? Prepares::GemfilePrepare })
        @review_checker ||= CodeAnalyzer::CheckingVisitor::Default.new(checkers: @reviews)
      end

      # lexical analysis the file.
      #
      # @param [String] filename of the file
      # @param [String] content of the file
      def lexical(filename, content)
        @lexical_checker.check(filename, content)
      end

      def after_lexical
        @lexical_checker.after_check
      end

      # prepare the file.
      #
      # @param [String] filename of the file
      # @param [String] content of the file
      def prepare(filename, content)
        @plain_prepare_checker.check(filename, content)
        @default_prepare_checker.check(filename, content)
      end

      def after_prepare
        @plain_prepare_checker.after_check
        @default_prepare_checker.after_check
      end

      # review the file.
      #
      # @param [String] filename of the file
      # @param [String] content of the file
      def review(filename, content)
        content = parse_html_template(filename, content)
        @review_checker.check(filename, content)
      end

      def after_review
        @review_checker.after_check
      end

      # get all errors from lexicals and reviews.
      #
      # @return [Array] all errors from lexicals and reviews
      def errors
        @errors ||= (@reviews + @lexicals).collect(&:errors).flatten
      end

      private

        # parse html template code, erb, haml and slim.
        #
        # @param [String] filename is the filename of the erb, haml or slim code.
        # @param [String] content is the source code of erb, haml or slim file.
        def parse_html_template(filename, content)
          if filename =~ /.*\.erb$|.*\.rhtml$/
            content = Erubis::OnlyRuby.new(content).src
          elsif filename =~ /.*\.haml$/
            begin
              require 'haml'
              content = Haml::Engine.new(content).precompiled
              # remove \xxx characters
              content.gsub!(/\\\d{3}/, '')
            rescue LoadError
              raise "In order to parse #{filename}, please install the haml gem"
            rescue Haml::Error, SyntaxError
              # do nothing, just ignore the wrong haml files.
            end
          elsif filename =~ /.*\.slim$/
            begin
              require 'slim'
              content = Slim::Engine.new.call(content)
            rescue LoadError
              raise "In order to parse #{filename}, please install the slim gem"
            rescue SyntaxError
              # do nothing, just ignore the wrong slim files
            end
          end
          content
        end

        # load all prepares.
        def load_prepares
          Prepares.constants.map { |prepare| Prepares.const_get(prepare).new }
        end

        # load all plugin reviews.
        def load_plugin_reviews
          begin
            plugins = File.join(Runner.base_path, 'lib', 'rails_best_practices', 'plugins', 'reviews')
            if File.directory?(plugins)
              Dir[File.expand_path(File.join(plugins, '*.rb'))].each do |review|
                require review
              end
              if RailsBestPractices.constants.map(&:to_sym).include? :Plugins
                RailsBestPractices::Plugins::Reviews.constants.each do |review|
                  @reviews << RailsBestPractices::Plugins::Reviews.const_get(review).new
                end
              end
            end
          end
        end
    end
  end
end
