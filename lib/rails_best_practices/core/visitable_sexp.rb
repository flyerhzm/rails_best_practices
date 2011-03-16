# encoding: utf-8
require 'sexp'

class Sexp
  # prepare current node.
  #
  # @param [RailsBestPractices::Core::CheckingVisitor] visitor the visitor to prepare current node
  def prepare(visitor)
    visitor.prepare(self)
  end

  # prepare current node.
  #
  # @param [RailsBestPractices::Core::CheckingVisitor] visitor the visitor to review current node
  def review(visitor)
    visitor.review(self)
  end

  # return child nodes of a sexp node.
  #
  #     s(:call, nil, :puts,
  #       s(:arglist, s(:str, "hello "), s(:str, "world"))
  #     )
  #       => [s(:arglist, s(:str, "hello "), s(:str, "world"))]
  #
  # @return [Array] child nodes.
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

  # grep all the recursive child nodes with conditions, and yield each match node.
  #
  # @param [Hash] options grep conditions
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

  # grep all the recursive child nodes with conditions, and yield the first match node.
  #
  # @param [Hash] options grep conditions
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
  def grep_node(options)
    grep_nodes(options) { |node| return node }
  end

  # grep all the recursive child nodes with conditions, and get the count of match nodes.
  #
  # @param [Hash] options grep conditions
  # @return [Integer] the count of metch nodes
  def grep_nodes_count(options)
    count = 0
    grep_nodes(options) { |node| count += 1 }
    count
  end

  # Get subject of attrasgan, call and iter node.
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
  #
  # @return [Sexp] subject of attrasgn, call or iter node
  def subject
    if [:attrasgn, :call, :iter].include? node_type
      self[1]
    end
  end

  # Get the class name of the class node.
  #
  #     s(:class, :User, nil, s(:scope))
  #         => :User
  #
  # @return [Symbol] class name of class node
  def class_name
    if :class == node_type
      self[1]
    end
  end

  # Get the base class of the class node.
  #
  #     s(:class, :User, s(:colon2, s(:const, :ActiveRecord), :Base), s(:scope))
  #         => s(:colon2, s(:const, :ActiveRecord), :Base)
  #
  # @return [Sexp] base class of class node
  def base_class
    if :class == node_type
      self[2]
    end
  end

  # Get the left value of the lasgn or iasgn node.
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
  #
  # @return [Symbol] left value of lasgn or iasgn node
  def left_value
    if [:lasgn, :iasgn].include? node_type
      self[1]
    end
  end

  # Get the right value of lasgn and iasgn node.
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
  #
  # @return [Sexp] right value of lasgn or iasgn node
  def right_value
    if [:lasgn, :iasgn].include? node_type
      self[2]
    end
  end

  # Get the message of attrasgn and call node.
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
  #
  # @return [Symbol] message of attrasgn or call node
  def message
    if [:attrasgn, :call].include? node_type
      self[2]
    end
  end

  # Get arguments of call node.
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
  #
  # @return [Sexp] arguments of attrasgn or call node
  def arguments
    if [:attrasgn, :call].include? node_type
      self[3]
    end
  end

  # Get the conditional statement of if node.
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
  #
  # @return [Sexp] conditional statement of if node
  def conditional_statement
    if :if == node_type
      self[1]
    end
  end

  # Get the body node when conditional statement is true.
  #
  #     s(:if,
  #       s(:call, s(:call, nil, :current_user, s(:arglist)), :login?, s(:arglist)),
  #       s(:call, s(:call, nil, :current_user, s(:arglist)), :login, s(:arglist)),
  #       s(:call, s(:call, nil, :current_user, s(:arglist)), :email, s(:arglist))
  #     )
  #         => s(:call, s(:call, nil, :current_user, s(:arglist)), :login, s(:arglist))
  #
  # @return [Sexp] the body node when conditional statement is true
  def true_node
    if :if == node_type
      self[2]
    end
  end

  # Get the body node when conditional statement is false.
  #
  #     s(:if,
  #       s(:call, s(:call, nil, :current_user, s(:arglist)), :login?, s(:arglist)),
  #       s(:call, s(:call, nil, :current_user, s(:arglist)), :login, s(:arglist)),
  #       s(:call, s(:call, nil, :current_user, s(:arglist)), :email, s(:arglist))
  #     )
  #         => s(:call, s(:call, nil, :current_user, s(:arglist)), :email, s(:arglist))
  #
  # @return [Sexp] the body node when conditional statement is false
  def false_node
    if :if == node_type
      self[3]
    end
  end

  # Get the method name of defn node.
  #
  #     s(:defn, :show, s(:args), s(:scope, s(:block, s(:nil))))
  #         => :show
  #
  # @return [Symbol] method name of defn node
  def method_name
    if :defn == node_type
      self[1]
    end
  end

  # Get body of iter, class and defn node.
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
  #
  # @return [Sexp] body of iter, class or defn node
  def body
    if :iter == node_type
      self[3]
    elsif :class == node_type
      self[3][1]
    elsif :defn == node_type
      self[3][1]
    end
  end

  # to_s for lvar, ivar, lit, const, array, hash, and colon2 node.
  #
  # @param [Hash] options
  #   :remove_at remove the @ symbol for ivar.
  # @return [String] to_s
  def to_s(options={})
    case node_type
    when :true, :false, :nil
      self[0].to_s
    when :ivar
      options[:remove_at] ? self[1].to_s[1..-1] : self[1].to_s
    when :lvar, :str, :lit, :const
      self[1].to_s
    when :array
      "[\"#{self.children.collect(&:to_s).join('", "')}\"]"
    when :hash
      key_value = false # false is key, true is value
      result = ['{']
      children.each do |child|
        if [:true, :false, :nil, :array, :hash].include? child.node_type
          result << "#{child}"
        else
          result << "\"#{child}\""
        end
        result << (key_value ? ", " : " => ")
        key_value = !key_value
      end
      result.join("").sub(/, $/, '') + '}'
    when :colon2
      "#{self[1]}::#{self[2]}"
    else
      ""
    end
  end

  # if the return value of these methods is nil, then return RailsBestPractices::Nil.new instead
  [:node_type, :subject, :message, :arguments, :class_name, :base_class, :method_name, :body, :conditional_statement, :true_node, :false_node, :left_value, :right_value].each do |method|
    class_eval <<-EOS
      alias_method :origin_#{method}, :#{method}

      def #{method}
        ret = origin_#{method}
        ret.nil? ? RailsBestPractices::Nil.new : ret
      end
    EOS
  end
end
