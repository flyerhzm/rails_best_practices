# encoding: utf-8
class NilClass
  # do not stop when causing messages on nil object.
  def method_missing(method_sym, *arguments, &block)
    return nil
  end
end

