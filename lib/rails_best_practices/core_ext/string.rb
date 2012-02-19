class String
  def table_name
    self.gsub("::", "").tableize
  end
end
