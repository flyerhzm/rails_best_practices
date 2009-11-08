require 'rubygems'
require 'ruby_parser'
require 'erb'
require 'yaml'

module RailsBestPractices
  module Core
    class Runner
      DEFAULT_CONFIG = File.join(File.dirname(__FILE__), "..", "..", "..", "rails_best_practices.yml")
      CUSTOM_CONFIG = File.join('config', 'rails_best_practices.yml')
      
      def initialize(*checks)
        if File.exists?(CUSTOM_CONFIG)
          @config = CUSTOM_CONFIG
        else
          @config = DEFAULT_CONFIG
        end
        @checks = checks unless checks.empty?
        @checks ||= load_checks
        @checker ||= CheckingVisitor.new(@checks)
        @parser = RubyParser.new
      end

      def check(filename, content)
        if filename =~ /.*erb/
          content = ERB.new(content).src
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
          @parser.parse(content, filename)
        rescue Exception => e
          puts "#{filename} looks like it's not a valid Ruby file.  Skipping..." if ENV["RBP_DEBUG"]
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
