# encoding: utf-8
require 'rubygems'
require 'ripper'
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

        lexicals = Array(options[:lexicals])
        prepares = Array(options[:prepares])
        reviews = Array(options[:reviews])
        @lexicals = lexicals.empty? ? load_lexicals : lexicals
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
        lexical(filename, read_file(filename))
      end

      # parepare a file's content with filename.
      #
      # @param [String] filename name of the file
      # @param [String] content content of the file
      def prepare(filename, content)
        puts filename if @debug
        node = parse_ruby(filename, content)
        if node
          node.file = filename
          node.prepare(@checker)
        end
      end

      # parapare the file.
      #
      # @param [String] filename
      def prepare_file(filename)
        prepare(filename, read_file(filename))
      end

      # review a file's content with filename.
      #
      # @param [String] filename name of the file
      # @param [String] content content of the file
      def review(filename, content)
        puts filename if @debug
        content = parse_erb_or_haml(filename, content)
        node = parse_ruby(filename, content)
        if node
          node.file = filename
          node.review(@checker)
        end
      end

      # review the file.
      #
      # @param [String] filename
      def review_file(filename)
        review(filename, read_file(filename))
      end

      # get all errors from lexicals and reviews.
      #
      # @return [Array] all errors from lexicals and reviews
      def errors
        (@reviews + @lexicals).collect {|check| check.errors}.flatten
      end

      # provide a handler after all files reviewed.
      def on_complete
        filename = "rails_best_practices.complete"
        content = "class RailsBestPractices::Complete; end"
        node = parse_ruby(filename, content)
        node.file = filename
        node.review(@checker)
      end

      private
        # parse ruby code.
        #
        # @param [String] filename is the filename of ruby file.
        # @param [String] content is the source code of ruby file.
        def parse_ruby(filename, content)
          begin
            Sexp.from_array(Ripper::SexpBuilder.new(content).parse)
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
        # @param [String] filename is the filename of the erb or haml code.
        # @param [String] content is the source code of erb or haml file.
        def parse_erb_or_haml(filename, content)
          if filename =~ /.*\.erb|.*\.rhtml$/
            content = Erubis::Eruby.new(content).src
          elsif filename =~ /.*\.haml$/
            begin
              require 'haml'
              content = Haml::Engine.new(content).precompiled
              # remove \xxx characters
              content.gsub!(/\\\d{3}/, '')
            rescue LoadError
              raise "In order to parse #{filename}, please install the haml gem"
            rescue Haml::Error
              # do nothing, just ignore the wrong haml files.
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
          [Prepares::ModelPrepare.new, Prepares::MailerPrepare.new, Prepares::SchemaPrepare.new, Prepares::ControllerPrepare.new]
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
            plugins = "#{Runner.base_path}lib/rails_best_practices/plugins/reviews"
            if File.directory?(plugins)
              Dir[File.expand_path(File.join(plugins, "*.rb"))].each do |review|
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

        # read the checks from yaml config.
        def checks_from_config
          @checks ||= YAML.load_file @config
        end

        # read the file content.
        #
        # @param [String] filename
        # @return [String] file conent
        def read_file(filename)
          File.open(filename, "r:UTF-8") { |f| f.read }
        end
    end
  end
end
