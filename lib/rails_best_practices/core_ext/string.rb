require 'inflecto'
class String
  def tableize
    Inflecto.tableize(self)
  end
  def camelize
    Inflecto.camelize(self)
  end
  def classify
    Inflecto.classify(self)
  end
  def pluralize
    Inflecto.pluralize(self)
  end
  def underscore
    Inflecto.underscore(self)
  end
end
