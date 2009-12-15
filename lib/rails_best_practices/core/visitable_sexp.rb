require 'rubygems'
require 'sexp'
require 'ruby2ruby'

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
    node_type = options[:node_type]
    subject = options[:subject]
    message = options[:message]
    arguments = options[:arguments]
    nodes = []
    self.recursive_children do |child|
      if (!node_type or node_type == child.node_type) and (!subject or subject == child.subject) and (!message or message == child.message) and (!arguments or arguments == child.arguments)
        nodes << child
      end
    end
    nodes
  end
  
  def subject
    if [:attrasgn, :call, :iasgn, :lasgn, :class].include? node_type
      self[1]
    end
  end
  
  def message
    if [:attrasgn, :call, :defs].include? node_type
      self[2]
    end
  end
  
  def arguments
    if [:attrasgn, :call].include? node_type
      self[3]
    end
  end
  
  def call
    if [:if, :arglist].include? node_type
      self[1]
    end
  end
  
  def conditional_statement
    if node_type == :if
      self[1]
    end
  end
  
  def true_node
    if :if == node_type
      self[2]
    end
  end
  
  def false_node
    if :if == node_type
      self[3]
    end
  end

  def message_name
    if :defn == node_type
      self[1]
    end
  end
  
  def body
    if :block == node_type
      self[1..-1]
    elsif :class == node_type
      self[3]
    elsif :defn == node_type
      self[3][1]
    elsif :defs == node_type
      self[4][1]
    end
  end

  def to_ruby
    Ruby2Ruby.new.process(self) unless self.empty?
  end
  
  def to_ruby_string
    return nil if self.empty?
    eval(Ruby2Ruby.new.process(self)).to_s
  end
end
