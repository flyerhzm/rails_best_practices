class Object
  def blank?
    self.nil? || self.empty?
  rescue
    false
  end
  def try(method_symbol)
    present? && public_send(method_symbol) || self
  end
  def present?
    !blank?
  end
end
