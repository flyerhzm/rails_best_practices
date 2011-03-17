# encoding: utf-8
module RailsBestPractices
  module Core
    class Nil
      def to_s(*arguments)
        self
      end

      # return self
      def method_missing(method_sym, *arguments, &block)
        self
      end
    end
  end
end
