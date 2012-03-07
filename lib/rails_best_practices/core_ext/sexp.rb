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

  # return the line number of a sexp node.
  #
  #     s(:@ident, "test", s(2, 12)
  #       => 2
  def line
    if [:def, :defs, :command, :command_call, :call, :fcall, :method_add_arg, :method_add_block,
      :var_ref, :vcall, :const_ref, :const_path_ref, :class, :module, :if, :unless, :elsif, :binary,
      :alias, :symbol_literal, :symbol, :aref].include? sexp_type
      self[1].line
    elsif :array == sexp_type
      array_values.first.line
    else
      self.last.first if self.last.is_a? Array
    end
  end

  # return child nodes of a sexp node.
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
  #     :sexp_type => :call,
  #     :subject => "Post",
  #     :message => ["find", "new"]
  #     :to_s => "devise"
  #
  # the condition key is one of :sexp_type, :subject, :message, :to_s,
  # the condition value can be Symbol, Array or Sexp.
  def grep_nodes(options)
    sexp_type = options[:sexp_type]
    subject = options[:subject]
    message = options[:message]
    to_s = options[:to_s]
    self.recursive_children do |child|
      if (!sexp_type || (sexp_type.is_a?(Array) ? sexp_type.include?(child.sexp_type) : sexp_type == child.sexp_type)) &&
         (!subject || (subject.is_a?(Array) ? subject.include?(child.subject.to_s) : subject == child.subject.to_s)) &&
         (!message || (message.is_a?(Array) ? message.include?(child.message.to_s) : message == child.message.to_s)) &&
         (!to_s || (to_s.is_a?(Array) ? to_s.include?(child.to_s) : to_s == child.to_s))
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
  #     :sexp_type => :call,
  #     :subject => s(:const, Post),
  #     :message => [:find, :new]
  #
  # the condition key is one of :sexp_type, :subject, :message, and to_s,
  # the condition value can be Symbol, Array or Sexp.
  def grep_node(options)
    result = RailsBestPractices::Core::Nil.new
    grep_nodes(options) { |node| result = node; break; }
    result
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

  # Get subject node.
  #
  #     s(:call,
  #       s(:var_ref,
  #         s(:@ident, "user", s(1, 0))
  #       ),
  #       :".",
  #       s(:@ident, "name", s(1, 5))
  #     )
  #         => s(:var_ref,
  #              s(:@ident, "user", s(1, 0))
  #            )
  #
  # @return [Sexp] subject node
  def subject
    case sexp_type
    when :assign, :field, :call, :binary, :command_call
      self[1]
    when :method_add_arg, :method_add_block
      self[1].subject
    end
  end

  # Get the module name of the module node.
  #
  #     s(:module,
  #       s(:const_ref, s(:@const, "Admin", s(1, 7))),
  #       s(:bodystmt, s(:stmts_add, s(:stmts_new), s(:void_stmt)), nil, nil, nil)
  #     )
  #         => s(:const_ref, s(:@const, "Admin", s(1, 7))),
  #
  # @return [Sexp] module name node
  def module_name
    if :module == sexp_type
      self[1]
    end
  end

  # Get the class name of the class node.
  #
  #     s(:class,
  #       s(:const_ref, s(:@const, "User", s(1, 6))),
  #       nil,
  #       s(:bodystmt, s(:stmts_add, s(:stmts_new), s(:void_stmt)), nil, nil, nil)
  #     )
  #         => s(:const_ref, s(:@const, "User", s(1, 6))),
  #
  # @return [Sexp] class name node
  def class_name
    if :class == sexp_type
      self[1]
    end
  end

  # Get the base class of the class node.
  #
  #     s(:class,
  #       s(:const_ref, s(:@const, "User", s(1, 6))),
  #       s(:const_path_ref, s(:var_ref, s(:@const, "ActiveRecord", s(1, 13))), s(:@const, "Base", s(1, 27))),
  #       s(:bodystmt, s(:stmts_add, s(:stmts_new), s(:void_stmt)), nil, nil, nil)
  #     )
  #         => s(:const_path_ref, s(:var_ref, s(:@const, "ActiveRecord", s(1, 13))), s(:@const, "Base", s(1, 27))),
  #
  # @return [Sexp] base class of class node
  def base_class
    if :class == sexp_type
      self[2]
    end
  end

  # Get the left value of the assign node.
  #
  #     s(:assign,
  #       s(:var_field, s(:@ident, "user", s(1, 0))),
  #       s(:var_ref, s(:@ident, "current_user", s(1, 7)))
  #     )
  #         => s(:var_field, s(:@ident, "user", s(1, 0))),
  #
  # @return [Symbol] left value of lasgn or iasgn node
  def left_value
    if :assign == sexp_type
      self[1]
    end
  end

  # Get the right value of assign node.
  #
  #     s(:assign,
  #       s(:var_field, s(:@ident, "user", s(1, 0))),
  #       s(:var_ref, s(:@ident, "current_user", s(1, 7)))
  #     )
  #         => s(:var_ref, s(:@ident, "current_user", s(1, 7)))
  #
  # @return [Sexp] right value of assign node
  def right_value
    if :assign == sexp_type
      self[2]
    end
  end

  # Get the message node.
  #
  #     s(:command,
  #       s(:@ident, "has_many", s(1, 0)),
  #       s(:args_add_block,
  #         s(:args_add, s(:args_new),
  #           s(:symbol_literal, s(:symbol, s(:@ident, "projects", s(1, 10))))
  #         ),
  #         false
  #       )
  #     )
  #         => s(:@ident, "has_many", s(1, 0)),
  #
  # @return [Symbol] message node
  def message
    case sexp_type
    when :command, :fcall
      self[1]
    when :binary
      self[2]
    when :command_call, :field, :call
      self[3]
    when :method_add_arg, :method_add_block
      self[1].message
    end
  end

  # Get arguments node.
  #
  #     s(:command,
  #       s(:@ident, "resources", s(1, 0)),
  #       s(:args_add_block,
  #         s(:args_add, s(:args_new),
  #           s(:symbol_literal, s(:symbol, s(:@ident, "posts", s(1, 11))))
  #         ), false
  #       )
  #     )
  #         => s(:args_add_block,
  #              s(:args_add, s(:args_new),
  #                s(:symbol_literal, s(:symbol, s(:@ident, "posts", s(1, 11))))
  #              ), false
  #            )
  #
  # @return [Sexp] arguments node
  def arguments
    case sexp_type
    when :command
      self[2]
    when :command_call
      self[4]
    when :method_add_arg
      self[2].arguments
    when :method_add_block
      self[1].arguments
    when :arg_paren
      self[1]
    when :array
      self
    end
  end

  # Get only argument for binary.
  #
  #     s(:binary,
  #       s(:var_ref, s(:@ident, "user", s(1, 0))),
  #       :==,
  #       s(:var_ref, s(:@ident, "current_user", s(1, 8)))
  #     )
  #         => s(:var_ref, s(:@ident, "current_user", s(1, 8)))
  #
  # @return [Sexp] argument node
  def argument
    if :binary == sexp_type
      self[3]
    end
  end

  # Get all arguments.
  #
  #     s(:args_add_block,
  #       s(:args_add,
  #         s(:args_add, s(:args_new), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "hello", s(1, 6))))),
  #         s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "world", s(1, 15))))
  #       ), false
  #     )
  #         => [
  #              s(:args_add, s(:args_new), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "hello", s(1, 6))))),
  #              s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "world", s(1, 15))))
  #            ]
  #
  # @return [Array] all arguments
  def all
    nodes = []
    case sexp_type
    when :args_add_block, :array
      if self[1].sexp_type == :args_new
        nodes << self[2]
      else
        node = self[1]
        while true
          if [:args_add, :args_add_star].include? node.sexp_type
            nodes.unshift node[2]
            node = node[1]
          elsif :args_new == node.sexp_type
            break
          end
        end
      end
    end
    nodes
  end

  # Get the conditional statement of if node.
  #
  #     s(:if,
  #       s(:var_ref, s(:@kw, "true", s(1, 3))),
  #       s(:stmts_add, s(:stmts_new), s(:void_stmt)),
  #       nil
  #     )
  #         => s(:var_ref, s(:@kw, "true", s(1, 3))),
  #
  # @return [Sexp] conditional statement of if node
  def conditional_statement
    if [:if, :unless, :elsif].include? sexp_type
      self[1]
    end
  end

  # Get all condition nodes.
  #
  #     s(:binary,
  #       s(:binary,
  #         s(:var_ref, s(:@ident, "user", s(1, 0))),
  #         :==,
  #         s(:var_ref, s(:@ident, "current_user", s(1, 8)))
  #       ),
  #       :"&&",
  #       s(:call,
  #         s(:var_ref, s(:@ident, "user", s(1, 24))),
  #         :".",
  #         s(:@ident, "valid?", s(1, 29))
  #       )
  #     )
  #         => [
  #              s(:binary,
  #                s(:var_ref, s(:@ident, "user", s(1, 0))),
  #                :==,
  #                s(:var_ref, s(:@ident, "current_user", s(1, 8)))
  #              ),
  #              s(:call,
  #                s(:var_ref, s(:@ident, "user", s(1, 24))),
  #                  :".",
  #                  s(:@ident, "valid?", s(1, 29))
  #              )
  #            ]
  #
  # @return [Array] all condition nodes
  def all_conditions
    nodes = []
    if :binary == sexp_type && %w(&& || and or).include?(self[2].to_s)
      if :binary == self[1].sexp_type && %w(&& || and or).include?(self[1][2].to_s)
        nodes += self[1].all_conditions
      else
        nodes << self[1]
      end
      if :binary == self[3].sexp_type && %w(&& || and or).include?(self[3][2].to_s)
        nodes += self[3].all_conditions
      else
        nodes << self[3]
      end
    else
      self
    end
  end

  # Get the method name of def node.
  #
  #     s(:def,
  #       s(:@ident, "show", s(1, 4)),
  #       s(:params, nil, nil, nil, nil, nil),
  #       s(:bodystmt, s(:stmts_add, s(:stmts_new), s(:void_stmt)), nil, nil, nil)
  #     )
  #         => s(:@ident, "show", s(1, 4)),
  #
  # @return [Sexp] method name node
  def method_name
    case sexp_type
    when :def
      self[1]
    when :defs
      self[3]
    else
    end
  end

  # Get body node.
  #
  #     s(:class,
  #       s(:const_ref, s(:@const, "User", s(1, 6))),
  #       nil,
  #       s(:bodystmt,
  #         s(:stmts_add, s(:stmts_new),
  #           s(:def,
  #             s(:@ident, "login", s(1, 16)),
  #             s(:params, nil, nil, nil, nil, nil),
  #             s(:bodystmt, s(:stmts_add, s(:stmts_new), s(:void_stmt)), nil, nil, nil)
  #           )
  #         ), nil, nil, nil
  #       )
  #     )
  #         => s(:bodystmt,
  #              s(:stmts_add, s(:stmts_new),
  #                s(:def,
  #                  s(:@ident, "login", s(1, 16)),
  #                  s(:params, nil, nil, nil, nil, nil),
  #                  s(:bodystmt, s(:stmts_add, s(:stmts_new), s(:void_stmt)), nil, nil, nil)
  #                )
  #              ), nil, nil, nil
  #            )
  #
  # @return [Sexp] body node
  def body
    case sexp_type
    when :else
      self[1]
    when :module, :if, :elsif, :unless
      self[2]
    when :class, :def
      self[3]
    when :defs
      self[5]
    end
  end

  # Get block node.
  #
  #     s(:method_add_block,
  #       s(:command,
  #         s(:@ident, "resources", s(1, 0)),
  #         s(:args_add_block, s(:args_add, s(:args_new), s(:symbol_literal, s(:symbol, s(:@ident, "posts", s(1, 11))))), false)
  #       ),
  #       s(:do_block, nil,
  #         s(:stmts_add, s(:stmts_add, s(:stmts_new), s(:void_stmt)),
  #           s(:command,
  #           s(:@ident, "resources", s(1, 21)),
  #           s(:args_add_block, s(:args_add, s(:args_new), s(:symbol_literal, s(:symbol, s(:@ident, "comments", s(1, 32))))), false))
  #         )
  #       )
  #     )
  #         => s(:do_block, nil,
  #              s(:stmts_add, s(:stmts_add, s(:stmts_new), s(:void_stmt)),
  #                s(:command,
  #                s(:@ident, "resources", s(1, 21)),
  #                s(:args_add_block, s(:args_add, s(:args_new), s(:symbol_literal, s(:symbol, s(:@ident, "comments", s(1, 32))))), false))
  #              )
  #            )
  #
  # @return [Sexp] body node
  def block
    case sexp_type
    when :method_add_block
      self[2]
    end
  end

  # Get all statements nodes.
  #
  #     s(:bodystmt,
  #       s(:stmts_add,
  #         s(:stmts_add, s(:stmts_new),
  #           s(:def,
  #             s(:@ident, "login?", s(1, 16)),
  #             s(:params, nil, nil, nil, nil, nil),
  #             s(:bodystmt, s(:stmts_add, s(:stmts_new), s(:void_stmt)), nil, nil, nil)
  #           )
  #         ),
  #         s(:def,
  #           s(:@ident, "admin?", s(1, 33)),
  #           s(:params, nil, nil, nil, nil, nil),
  #           s(:bodystmt, s(:stmts_add, s(:stmts_new), s(:void_stmt)), nil, nil, nil)
  #         )
  #       ), nil, nil, nil
  #     )
  #         => [
  #              s(:def,
  #                s(:@ident, "login?", s(1, 16)),
  #                s(:params, nil, nil, nil, nil, nil),
  #                s(:bodystmt, s(:stmts_add, s(:stmts_new), s(:void_stmt)), nil, nil, nil)
  #              ),
  #              s(:def,
  #                s(:@ident, "admin?", s(1, 33)),
  #                s(:params, nil, nil, nil, nil, nil),
  #                s(:bodystmt, s(:stmts_add, s(:stmts_new), s(:void_stmt)), nil, nil, nil)
  #              )
  #            ]
  #
  # @return [Array] all statements
  def statements
    stmts = []
    node = case sexp_type
           when :do_block
             self[2]
           when :bodystmt
             self[1]
           else
           end
    if node
      while true
        if :stmts_add == node.sexp_type && s(:void_stmt) != node[2]
          stmts.unshift node[2]
          node = node[1]
        else
          break
        end
      end
    end
    stmts
  end

  # Get hash value node.
  #
  #     s(:hash,
  #       s(:assoclist_from_args,
  #         s(
  #           s(:assoc_new, s(:@label, "first_name:", s(1, 1)), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "Richard", s(1, 14))))),
  #           s(:assoc_new, s(:@label, "last_name:", s(1, 24)), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "Huang", s(1, 36)))))
  #         )
  #       )
  #     )
  #         => s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "Richard", s(1, 14))))
  #
  # @return [Sexp] hash value node
  def hash_value(key)
    pair_nodes = case sexp_type
                 when :bare_assoc_hash
                   self[1]
                 when :hash
                   self[1][1]
                 else
                 end
    if pair_nodes
      pair_nodes.size.times do |i|
        if key == pair_nodes[i][1].to_s
          return pair_nodes[i][2]
        end
      end
    end
    RailsBestPractices::Core::Nil.new
  end

  # Get hash size.
  #
  #     s(:hash,
  #       s(:assoclist_from_args,
  #         s(
  #           s(:assoc_new, s(:@label, "first_name:", s(1, 1)), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "Richard", s(1, 14))))),
  #           s(:assoc_new, s(:@label, "last_name:", s(1, 24)), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "Huang", s(1, 36)))))
  #         )
  #       )
  #     )
  #         => 2
  #
  # @return [Integer] hash size
  def hash_size
    case sexp_type
    when :hash
      self[1].hash_size
    when :assoclist_from_args
      self[1].size
    when :bare_assoc_hash
      self[1].size
    end
  end

  # Get the hash keys.
  #
  #     s(:hash,
  #       s(:assoclist_from_args,
  #         s(
  #           s(:assoc_new, s(:@label, "first_name:", s(1, 1)), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "Richard", s(1, 14))))),
  #           s(:assoc_new, s(:@label, "last_name:", s(1, 24)), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "Huang", s(1, 36)))))
  #         )
  #       )
  #     )
  #         => ["first_name", "last_name"]
  #
  # @return [Array] hash keys
  def hash_keys
    pair_nodes = case sexp_type
                 when :bare_assoc_hash
                   self[1]
                 when :hash
                   self[1][1]
                 else
                 end
    if pair_nodes
      keys = []
      pair_nodes.size.times do |i|
        keys << pair_nodes[i][1].to_s
      end
      keys
    end
  end

  # Get the hash values.
  #
  #     s(:hash,
  #       s(:assoclist_from_args,
  #         s(
  #           s(:assoc_new, s(:@label, "first_name:", s(1, 1)), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "Richard", s(1, 14))))),
  #           s(:assoc_new, s(:@label, "last_name:", s(1, 24)), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "Huang", s(1, 36)))))
  #         )
  #       )
  #     )
  #         => [
  #              s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "Richard", s(1, 14)))),
  #              s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "Huang", s(1, 36))))
  #            ]
  #
  # @return [Array] hash values
  def hash_values
    pair_nodes = case sexp_type
                 when :bare_assoc_hash
                   self[1]
                 when :hash
                   self[1][1]
                 else
                 end
    if pair_nodes
      values = []
      pair_nodes.size.times do |i|
        values << pair_nodes[i][2]
      end
      values
    end
  end

  # Get the array size.
  #
  #     s(:array,
  #       s(:args_add,
  #         s(:args_add, s(:args_new), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "first_name", s(1, 2))))),
  #         s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "last_name", s(1, 16))))
  #       )
  #     )
  #         => 2
  #
  # @return [Integer] array size
  def array_size
    if :array == sexp_type
      first_node = self[1]
      array_size = 0
      if first_node
        while true
          array_size += 1
          first_node = s(:args_new) == first_node[1] ? first_node[2] : first_node[1]
          if :args_add != first_node.sexp_type
            if :array == first_node.sexp_type
              array_size += first_node.array_size
            end
            break
          end
        end
      end
      array_size
    end
  end

  # Get the array values.
  #
  #     s(:array,
  #       s(:args_add,
  #         s(:args_add, s(:args_new), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "first_name", s(1, 2))))),
  #         s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "last_name", s(1, 16))))
  #       )
  #     )
  #         => [
  #              s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "first_name", s(1, 2)))),
  #              s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "last_name", s(1, 16))))
  #            ]
  #
  # @return [Array] array values
  def array_values
    if :array == sexp_type
      if nil == self[1]
        []
      elsif :qwords_add == self[1].sexp_type
        self[1].array_values
      else
        arguments.all
      end
    elsif :qwords_add
      values = []
      node = self
      while true
        if :qwords_add == node.sexp_type
          values.unshift node[2]
          node = node[1]
        elsif :qwords_new == node.sexp_type
          break
        end
      end
      values
    end
  end

  # old method for alias node.
  #
  #     s(:alias,
  #       s(:symbol_literal, s(:@ident, "new", s(1, 6))),
  #       s(:symbol_literal, s(:@ident, "old", s(1, 10)))
  #     )
  #         => s(:symbol_literal, s(:@ident, "old", s(1, 10))),
  def old_method
    self[2]
  end

  # new method for alias node.
  #
  #     s(:alias,
  #       s(:symbol_literal, s(:@ident, "new", s(1, 6))),
  #       s(:symbol_literal, s(:@ident, "old", s(1, 10)))
  #     )
  #         => s(:symbol_literal, s(:@ident, "new", s(1, 6))),
  def new_method
    self[1]
  end

  # To object.
  #
  #     s(:array,
  #       s(:args_add,
  #         s(:args_add, s(:args_new), s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "first_name", s(1, 2))))),
  #         s(:string_literal, s(:string_add, s(:string_content), s(:@tstring_content, "last_name", s(1, 16))))
  #       )
  #     )
  #         => ["first_name", "last_name"]
  #
  # @return [Object]
  def to_object
    case sexp_type
    when :array
      if nil == self[1]
        []
      else
        arguments.all.map(&:to_s)
      end
    else
      to_s
    end
  end

  # to_s.
  #
  # @return [String] to_s
  def to_s
    case sexp_type
    when :string_literal, :xstring_literal, :string_content, :const_ref, :symbol_literal, :symbol,
         :args_add_block, :var_ref, :vcall, :var_field,
         :@ident, :@tstring_content, :@const, :@ivar, :@kw, :@gvar, :@cvar
      self[1].to_s
    when :string_add
      if s(:string_content) == self[1]
        self[2].to_s
      else
        self[1].to_s
      end
    when :args_add
      if s(:args_new) == self[1]
        self[2].to_s
      else
        self[1].to_s
      end
    when :qwords_add
      if s(:qwords_new) == self[1]
        self[2].to_s
      else
        self[1].to_s
      end
    when :const_path_ref
      "#{self[1]}::#{self[2]}"
    when :@label
      self[1].to_s[0..-2]
    when :aref
      "#{self[1]}[#{self[2]}]"
    else
      ""
    end
  end

  # check if the self node is a const.
  def const?
    :@const == self.sexp_type || ([:var_ref, :vcall].include?(self.sexp_type) && :@const == self[1].sexp_type)
  end

  # true
  def present?
    true
  end

  # false
  def blank?
    false
  end

  # remove the line and column info from sexp.
  def remove_line_and_column
    node = self.clone
    last_node = node.last
    if Sexp === last_node && last_node.size == 2 && last_node.first.is_a?(Integer) && last_node.last.is_a?(Integer)
      node.delete_at(-1)
    end
    node.sexp_body.each_with_index do |child, index|
      if Sexp === child
        node[index+1] = child.remove_line_and_column
      end
    end
    node
  end

  # if the return value of these methods is nil, then return RailsBestPractices::Core::Nil.new instead
  [:sexp_type, :subject, :message, :arguments, :argument, :class_name, :base_class, :method_name, :body, :block, :conditional_statement, :left_value, :right_value].each do |method|
    class_eval <<-EOS
      alias_method :origin_#{method}, :#{method}

      def #{method}
        ret = origin_#{method}
        ret.nil? ? RailsBestPractices::Core::Nil.new : ret
      end
    EOS
  end
end
