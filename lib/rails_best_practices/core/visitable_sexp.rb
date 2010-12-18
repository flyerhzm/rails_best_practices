# encoding: utf-8
require 'sexp'

class Sexp
  def prepare(visitor)
    visitor.prepare(self)
  end

  def review(visitor)
    visitor.review(self)
  end

  # return child nodes of a sexp node.
  #
  #     s(:call, nil, :puts,
  #       s(:arglist, s(:str, "hello "), s(:str, "world"))
  #     )
  #       => [s(:arglist, s(:str, "hello "), s(:str, "world"))]
  def children
    find_all { | sexp | Sexp === sexp }
  end

  # recursively find all child nodes, and yeild each child node.
  def recursive_children
    children.each do |child|
      yield child
      child.recursive_children { |c| yield c }
    end
  end

  # grep all the recursive child ndoes with conditions, and yield each match node.
  #
  # options is the grep conditions, like
  #
  #     :node_type => :call,
  #     :subject => s(:const, Post),
  #     :message => [:find, :new],
  #     :arguments => s(:arglist)
  #
  # the condition key is one of :node_type, :subject, :message or :arguments,
  # the condition value can be Symbol, Array or Sexp.
  def grep_nodes(options)
    node_type = options[:node_type]
    subject = options[:subject]
    message = options[:message]
    arguments = options[:arguments]
    self.recursive_children do |child|
      if (!node_type || (node_type.is_a?(Array) ? node_type.include?(child.node_type) : node_type == child.node_type)) &&
         (!subject || (subject.is_a?(Array) ? subject.include?(child.subject) : subject == child.subject)) &&
         (!message || (message.is_a?(Array) ? message.include?(child.message) : message == child.message)) &&
         (!arguments || (arguments.is_?(Array) ? arguments.include?(child.arguments) : arguments == child.arguments))
        yield child
      end
    end
  end

  # like grep_nodes, except that return the first match node.
  def grep_node(options)
    grep_nodes(options) { |node| return node }
  end

  # return the count of grep_nodes.
  def grep_nodes_count(options)
    count = 0
    grep_nodes(options) { |node| count += 1 }
    count
  end

  # return subject of attrasgan, call and iter node.
  #
  #     s(:attrasgn,
  #       s(:call, nil, :user, s(:arglist)),
  #       :name=,
  #       s(:arglist,
  #         s(:call,
  #           s(:call, nil, :params, s(:arglist)),
  #           :[],
  #           s(:arglist, s(:lit, :name))
  #         )
  #       )
  #     )
  #         => s(:call, nil, :user, s(:arglist))
  #
  #     s(:call,
  #       s(:call, nil, :user, s(:arglist)),
  #       :name,
  #       s(:arglist)
  #     )
  #         => s(:call, nil, :user, s(:arglist))
  #
  #     s(:iter,
  #       s(:call, s(:ivar, :@users), :each, s(:arglist)),
  #       s(:lasgn, :user),
  #       s(:call, nil, :p,
  #         s(:arglist, s(:lvar, :user))
  #       )
  #     )
  #         => s(:call, :s(:ivar, ;@users), :each, s(:arglist))
  def subject
    if [:attrasgn, :call, :iter].include? node_type
      self[1]
    end
  end

  # return the class name of the class node.
  #
  #     s(:class, :User, nil, s(:scope))
  #         => :User
  def class_name
    if :class == node_type
      self[1]
    end
  end

  # return the base class of the class node.
  #
  #     s(:class, :User, s(:colon2, s(:const, :ActiveRecord), :Base), s(:scope))
  #         => s(:colon2, s(:const, :ActiveRecord), :Base)
  def base_class
    if :class == node_type
      self[2]
    end
  end

  # return the left value of the lasgn or iasgn node.
  #
  #     s(:lasgn,
  #       :user,
  #       s(:call,
  #         s(:call, nil, :params, s(:arglist)),
  #         :[],
  #         s(:arglist, s(:lit, :user))
  #       )
  #     )
  #         => :user
  #
  #     s(:iasgn,
  #       :@user,
  #       s(:call,
  #         s(:call, nil, :params, s(:arglist)),
  #         :[],
  #         s(:arglist, s(:lit, :user))
  #       )
  #     )
  #         => :@user
  def left_value
    if [:lasgn, :iasgn].include? node_type
      self[1]
    end
  end

  # return the right value of lasgn and iasgn node.
  #
  #     s(:lasgn,
  #       :user,
  #       s(:call, nil, :current_user, s(:arglist))
  #     )
  #         => s(:call, nil, :current_user, s(:arglist))
  #
  #     s(:iasgn,
  #       :@user,
  #       s(:call, nil, :current_user, s(:arglist))
  #     )
  #         => s(:call, nil, :current_user, s(:arglist))
  def right_value
    if [:lasgn, :iasgn].include? node_type
      self[2]
    end
  end

  # message of attrasgn and call node.
  #
  #     s(:attrasgn,
  #       s(:call, nil, :user, s(:arglist)),
  #       :name=,
  #       s(:arglist,
  #         s(:call,
  #           s(:call, nil, :params, s(:arglist)),
  #           :[],
  #           s(:arglist, s(:lit, :name))
  #         )
  #       )
  #     )
  #         => :name=
  #
  #     s(:call, nil, :has_many, s(:arglist, s(:lit, :projects)))
  #         => :has_many
  def message
    if [:attrasgn, :call].include? node_type
      self[2]
    end
  end

  # return arguments of call node.
  #
  #     s(:attrasgn,
  #       s(:call, nil, :post, s(:arglist)),
  #       :user=,
  #       s(:arglist,
  #         s(:call, nil, :current_user, s(:arglist))
  #       )
  #     )
  #         => s(:arglist, s(:call, nil, :current_user, s(:arglist)))
  #
  #     s(:call,
  #       s(:call, nil, :username, s(:arglist)),
  #       :==,
  #       s(:arglist, s(:str, ""))
  #     )
  #         => s(:arglist, s(:str, ""))
  def arguments
    if [:attrasgn, :call].include? node_type
      self[3]
    end
  end

  # return the conditional statement of if node.
  #
  #     s(:if,
  #       s(:call,
  #         s(:call, nil, :current_user, s(:arglist)),
  #         :present?,
  #         s(:arglist)
  #       ),
  #       s(:call, nil, :puts,
  #         s(:arglist,
  #           s(:call,
  #             s(:call, nil, :current_user, s(:arglist)),
  #             :login,
  #             s(:arglist)
  #           )
  #         )
  #       ),
  #       nil
  #     )
  #         => s(:call, s(:call, nil, :current_user, s(:arglist)), :present?, s(:arglist))
  def conditional_statement
    if :if == node_type
      self[1]
    end
  end

  # return the body node when conditional statement is true.
  #
  #     s(:if,
  #       s(:call, s(:call, nil, :current_user, s(:arglist)), :login?, s(:arglist)),
  #       s(:call, s(:call, nil, :current_user, s(:arglist)), :login, s(:arglist)),
  #       s(:call, s(:call, nil, :current_user, s(:arglist)), :email, s(:arglist))
  #     )
  #         => s(:call, s(:call, nil, :current_user, s(:arglist)), :login, s(:arglist))
  def true_node
    if :if == node_type
      self[2]
    end
  end

  # return the body node when conditional statement is false.
  #
  #     s(:if,
  #       s(:call, s(:call, nil, :current_user, s(:arglist)), :login?, s(:arglist)),
  #       s(:call, s(:call, nil, :current_user, s(:arglist)), :login, s(:arglist)),
  #       s(:call, s(:call, nil, :current_user, s(:arglist)), :email, s(:arglist))
  #     )
  #         => s(:call, s(:call, nil, :current_user, s(:arglist)), :email, s(:arglist))
  def false_node
    if :if == node_type
      self[3]
    end
  end

  # return the method name of defn node.
  #
  #     s(:defn, :show, s(:args), s(:scope, s(:block, s(:nil))))
  #         => :show
  def method_name
    if :defn == node_type
      self[1]
    end
  end

  # return body of iter, class and defn node.
  #
  #     s(:iter,
  #       s(:call, nil, :resources, s(:arglist, s(:lit, :posts))),
  #       nil,
  #       s(:call, nil, :resources, s(:arglist, s(:lit, :comments)))
  #     )
  #         => s(:call, nil, :resources, s(:arglist, s(:lit, :comments)))
  #
  #     s(:class, :User, nil,
  #       s(:scope,
  #         s(:block,
  #           s(:defn, :login, s(:args), s(:scope, s(:block, s(:nil)))),
  #           s(:defn, :email, s(:args), s(:scope, s(:block, s(:nil))))
  #         )
  #       )
  #     )
  #         => s(:block,
  #              s(:defn, :login, s(:args), s(:scope, s(:block, s(:nil)))),
  #              s(:defn, :email, s(:args), s(:scope, s(:block, s(:nil))))
  #            )
  #
  #     s(:defn, :fullname, s(:args),
  #       s(:scope,
  #         s(:block,
  #           s(:call,
  #             s(:call,
  #               s(:call, nil, :first_name, s(:arglist)),
  #               :+,
  #               s(:arglist,
  #                 s(:call, nil, :last, s(:arglist))
  #               )
  #             ),
  #             :+,
  #             s(:arglist,
  #               s(:call, nil, :name, s(:arglist))
  #             )
  #           )
  #         )
  #       )
  #     )
  #         => s(:block,
  #              s(:call,
  #                s(:call,
  #                  s(:call, nil, :first_name, s(:arglist)),
  #                  :+,
  #                  s(:arglist,
  #                    s(:call, nil, :last, s(:arglist))
  #                  )
  #                ),
  #                :+,
  #                s(:arglist,
  #                  s(:call, nil, :name, s(:arglist))
  #                )
  #              )
  #            )
  def body
    if :iter == node_type
      self[3]
    elsif :class == node_type
      self[3][1]
    elsif :defn == node_type
      self[3][1]
    end
  end

  # to_s for lvar, ivar, lit, const, array and hash.
  def to_s
    if [:lvar, :ivar].include? node_type
      self[1].to_s
    elsif :str == node_type
      self[1]
    elsif :lit == node_type
      self[1].to_s
    elsif :const == node_type
      self[1].to_s
    elsif :array == node_type
      "[\"#{self.children.collect(&:to_s).join('", "')}\"]"
    elsif :hash == node_type
      key_value = false # false is key, true is value
      result = ['{"']
      children.each do |child|
        result << "#{child.to_s}#{key_value ? '", "' : '" => "'}"
        key_value = !key_value
      end
      result.join("").sub(/, "$/, '') + '}'
    end
  end
end
