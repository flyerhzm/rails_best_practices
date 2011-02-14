# encoding: utf-8
class NilClass
  # compatible with Sexp#to_s(options={})
  def to_s(options={})
    nil
  end

  # do not raise error when calling messages on nil object.
  def method_missing(method_sym, *arguments, &block)
    return nil
  end
end

