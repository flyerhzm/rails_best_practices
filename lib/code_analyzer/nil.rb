# encoding: utf-8
module CodeAnalyzer
  # Fake nil.
  class Nil
    # hash_size is 0.
    def hash_size
      0
    end

    # array_size is 0.
    def array_size
      0
    end

    # return self for to_s.
    def to_s
      self
    end

    # false
    def present?
      false
    end

    # true
    def blank?
      true
    end

    # return self.
    def method_missing(method_sym, *arguments, &block)
      self
    end
  end
end
