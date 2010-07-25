require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check to make sure not avoid the law of demeter.
    # 
    # Implementation: 
    # 1. check all models to record belongs_to and has_one associations
    # 2. check if calling belongs_to and has_one association's method or attribute
    class LawOfDemeterCheck < Check
      
      def interesting_nodes
        [:call, :class]
      end

      def initialize
        super
        @associations = {}
      end

      def evaluate_start(node)
        if node.node_type == :class
          remember_association(node)
        elsif [:lvar, :ivar].include?(node.subject.node_type) and node.subject != s(:lvar, :_erbout)
          add_error "law of demeter" if need_delegate?(node)
        end
      end

      private

      # remember belongs_to or has_one node
      def remember_association(node)
        (node.body.grep_nodes(:message => :belongs_to) + node.body.grep_nodes(:message => :has_one)).collect do |body_node|
          class_name = node.subject.to_s.underscore
          @associations[class_name] ||= []
          @associations[class_name] << body_node.arguments[1].to_ruby_string
        end
      end

      def need_delegate?(node)
        @associations.each do |class_name, associations|
          return true if node.subject.to_ruby =~ /#{class_name}$/ and associations.include? node.message.to_s
        end
        false
      end
    end
  end
end
