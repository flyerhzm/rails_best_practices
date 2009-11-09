require 'rails_best_practices/core/error'

module RailsBestPractices
  module Checks
    class Check
      NODE_TYPES = [:call, :defn, :defs, :if, :unless, :class, :lasgn]

      def initialize
        @errors = []
      end
      
      def interesting_files
        /.*/
      end
  
      NODE_TYPES.each do |node|
        start_node_method = "evaluate_start_#{node}"
        end_node_method = "evaluate_end_#{node}"
        define_method(start_node_method) { |node| } unless self.respond_to?(start_node_method)
        define_method(end_node_method) { |node| } unless self.respond_to?(end_node_method)
      end

      def position(offset = 0)
        "#{@line[2]}:#{@line[1] + offset}"
      end
      
      def evaluate_start(node)
      end

      def evaluate_end(node)
      end

      def evaluate_node(position, node)
        @node = node
        eval_method = "evaluate_#{position}_#{node.node_type}"
        self.send(eval_method, node)
      end

      def evaluate_node_start(node)
        evaluate_node(:start, node)
        evaluate_start(node)
      end
  
      def evaluate_node_end(node)
        evaluate_node(:end, node)
        evaluate_end(node)
      end
      
      def add_error(error, line = nil)
        line = @node.line if line.nil?
        @errors << RailsBestPractices::Core::Error.new("#{@node.file}", "#{line}", error)
      end
  
      def errors
        @errors
      end
    end
  end
end
