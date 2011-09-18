# encoding: utf-8
module RailsBestPractices
  module Core
    class Nil
      def hash_size
        0
      end

      def to_s
        self
      end

      # return self
      def method_missing(method_sym, *arguments, &block)
        self
      end
    end
  end
end
