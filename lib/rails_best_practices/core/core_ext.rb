# encoding: utf-8
module Enumerable
  # return the duplicated entries.
  def dups
    inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
  end
end

class NilClass
  # do not stop when causing messages on nil object.
  def method_missing(method_sym, *arguments, &block)
    return nil
  end
end
