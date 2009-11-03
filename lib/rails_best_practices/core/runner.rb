require 'rubygems'
require 'ruby_parser'
require 'yaml'

module RailsBestPractices
  module Core
    class Runner
      DEFAULT_CONFIG = File.join(File.dirname(__FILE__), "..", "..", "..", "rails_best_practices.yml")
      
      def initialize(*checks)
        @config = DEFAULT_CONFIG
        @checks = checks unless checks.empty?
        @checks ||= load_checks
        @checker ||= CheckingVisitor.new(@checks)
        @parser = RubyParser.new
      end

      def check(filename, content)
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
          puts "#{filename} looks like it's not a valid Ruby file.  Skipping..." if ENV["ROODI_DEBUG"]
          nil
        end
      end
    end
  end
end