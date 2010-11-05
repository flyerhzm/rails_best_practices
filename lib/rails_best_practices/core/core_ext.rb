# encoding: utf-8
module Enumerable
  def dups
    inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
  end
end

class NilClass
  def method_missing(method_sym, *arguments, &block)
    return nil
  end
end
