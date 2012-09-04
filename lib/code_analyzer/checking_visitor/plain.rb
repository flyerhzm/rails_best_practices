# encoding: utf-8
module CodeAnalyzer::CheckingVisitor
  class Plain
    def initialize(options={})
      @checkers = options[:checkers]
    end

    def check(filename, content)
      @checkers.each do |checker|
        checker.check(filename, content)
      end
    end
  end
end
