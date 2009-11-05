require 'rubygems'
require 'sexp'

class Sexp
  def accept(visitor)
    visitor.visit(self)
  end

  def node_type
    first
  end

  def children
    find_all { | sexp | Sexp === sexp }
  end
  
  def is_language_node?
    first.class == Symbol
  end
  
  def visitable_children
    parent = is_language_node? ? sexp_body : self
    parent.children
  end
  
  def recursive_children(&handler)
    visitable_children.each do |child|
      handler.call child
      child.recursive_children(&handler)
    end
  end
  
  def grep_nodes(options)
    return self if options.empty?
    subject = options[:subject]
    message = options[:message]
    arguments = options[:arguments]
    nodes = []
    self.recursive_children do |child|
      if (!subject or subject == child.subject) and (!message or message == child.message) and (!arguments or arguments == child.arguments)
        nodes << child
      end
    end
    nodes
  end
  
  def subject
    case node_type
    when :attrasgn, :call, :iasgn, :lasgn
      self[1]
    else
    end
  end
  
  def message
    case node_type
    when :attrasgn, :call
      self[2]
    else
    end
  end
  
  def arguments
    case node_type
    when :attrasgn, :call
      self[3]
    else
    end
  end
  
  def call
    case node_type
    when :if, :arglist
      self[1]
    else
    end
  end
  
  def true_node
    case node_type
    when :if
      self[2]
    else
    end
  end
  
  def false_node
    case node_type
    when :if
      self[3]
    else
    end
  end
  
  def method_body
    case node_type
    when :block
      self[1..-1]
    else
    end
  end
end
