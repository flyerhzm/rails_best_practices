# encoding: utf-8
module Enumerable
  # Get the duplicate entries from an Enumerable.
  #
  # @return [Enumerable] the duplicate entries.
  def dups
    inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
  end
end
