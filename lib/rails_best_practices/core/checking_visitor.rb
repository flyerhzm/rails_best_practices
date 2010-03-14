module RailsBestPractices
  module Core
    class CheckingVisitor
      def initialize(checks)
        @checks ||= {}
        checks.each do |check|
          nodes = check.interesting_nodes
          nodes.each do |node|
            @checks[node] ||= []
            @checks[node] << check
            @checks[node].uniq!
          end
        end
      end

    	def visit(node)
        checks = @checks[node.node_type]
        checks.each {|check| check.evaluate_node_start(node) if node.file =~ check.interesting_files} unless checks.nil?

    		node.visitable_children.each {|sexp| sexp.accept(self)}

        checks.each {|check| check.evaluate_node_end(node) if node.file =~ check.interesting_files} unless checks.nil?
    	end
    end
  end
end
