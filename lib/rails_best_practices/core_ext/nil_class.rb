# encoding: utf-8
class NilClass
  # do not raise error when calling messages on nil object.
  def method_missing(method_sym, *arguments, &block)
    return nil
  end
end

