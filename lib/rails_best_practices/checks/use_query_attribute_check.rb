# encoding: utf-8
require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check to make sure use query attribute instead of nil?, blank? and present?.
    # 
    # Implementation: 
    # 1. check all models to save model names and association names.
    #    model names are used for detecting
    #    association name should not be detected as query attribute
    # 2. check all method calls, if their subjects are model names and their messages are one of nil?,
    #    blank?, present? or == "", not pluralize and not in the association names, 
    #    then they need to use query attribute.
    class UseQueryAttributeCheck < Check
      
      QUERY_METHODS = [:nil?, :blank?, :present?]
      ASSOCIATION_METHODS = [:belongs_to, :has_one, :has_many, :has_and_belongs_to_many]
      
      def interesting_nodes
        [:if, :class, :call]
      end

      def initialize
        super
        @klazzes = []
        @associations = {}
      end

      def evaluate_start(node)
        case node.node_type
        when :class
          remember_klazz(node)
        when :call
          remember_association(node) if ASSOCIATION_METHODS.include? node.message
        when :if
          add_error "use query attribute", node.file, node.line if need_query_attribute?(node.conditional_statement)
        else
        end
      end

      private

      def remember_klazz(class_node)
        if class_node.file =~ MODLE_FILES
          @klazzes << class_node.subject
        end
      end
      
      def remember_association(association_node)
        @associations[@klazzes.last] ||= []
        @associations[@klazzes.last] << association_node.arguments[1].to_s
      end

      def need_query_attribute?(conditional_statement_node)
        case conditional_statement_node.node_type
        when :and, :or
          return need_query_attribute?(conditional_statement_node[1]) || need_query_attribute?(conditional_statement_node[2])
        when :not
          return need_query_attribute?(conditional_statement_node[1])
        when :call
          return true if query_method?(conditional_statement_node) or compare_with_empty_string?(conditional_statement_node)
        end
        false
      end
      
      def query_method?(node)
        return false unless :call == node.subject.node_type
        subject = node.subject.subject
        message = node.subject.message
        subject_ruby = subject.to_s
        
        subject_ruby && @klazzes.find { |klazz| subject_ruby =~ %r|#{klazz.to_s.underscore}| and !@associations[klazz].find { |association| equal?(association, message) } } &&
        message && message.to_s.pluralize != message.to_s &&
        QUERY_METHODS.include?(node.message)
      end
      
      def compare_with_empty_string?(node)
        :== == node.message and [:arglist, [:str, ""]] == node.arguments
      end
    end
  end
end
