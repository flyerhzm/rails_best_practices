# encoding: utf-8
require 'rubygems'
require 'ruby_parser'
require 'erb'
require 'yaml'
require 'active_support/inflector'

module RailsBestPractices
  module Core
    class Runner
      attr_reader :checks

      DEFAULT_CONFIG = File.join(File.dirname(__FILE__), "..", "..", "..", "rails_best_practices.yml")
      CUSTOM_CONFIG = File.join('config', 'rails_best_practices.yml')

      def initialize(*checks)
        @config = File.exists?(CUSTOM_CONFIG) ? CUSTOM_CONFIG : DEFAULT_CONFIG
        @checks = checks unless checks.empty?
        @checks ||= load_checks
        @checker ||= CheckingVisitor.new(@checks)
        @debug = false
      end

      def set_debug
        @debug = true
      end

      def check(filename, content)
        puts filename if @debug
        if filename =~ /.*\.erb$/
          content = ERB.new(content).src
          # remove the coding line which exists in Ruby 1.9
          content.gsub!(/#coding:US-ASCII\n/, '')
        end
        if filename =~ /.*\.haml$/
          begin
            require 'haml'
            content = Haml::Engine.new(content).precompiled
            # remove \xxx characters
            content.gsub!(/\\\d{3}/, '')
          rescue Haml::SyntaxError
          end
        end
        node = parse(filename, content)
        node.accept(@checker) if node
      end

      def check_content(content)
        check("dummy-file.rb", content)
      end

      def check_file(filename)
        check(filename, File.read(filename))
      end

      def errors
        @checks ||= []
        all_errors = @checks.collect {|check| check.errors}
        all_errors.flatten
      end

      private

      def parse(filename, content)
        begin
          RubyParser.new.parse(content, filename)
        rescue Exception => e
          puts "#{filename} looks like it's not a valid Ruby file.  Skipping..." if @debug
          nil
        end
      end

      def load_checks
        check_objects = []
        checks = YAML.load_file @config
        checks.each do |check|
          klass = eval("RailsBestPractices::Checks::#{check[0]}")
          check_objects << (check[1].empty? ? klass.new : klass.new(check[1]))
        end
        check_objects
      end
    end
  end
end
