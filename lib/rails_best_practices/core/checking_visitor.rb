# encoding: utf-8
module RailsBestPractices
  module Core
    class CheckingVisitor
      def initialize(checks)
        @prepare_checks ||= {}
        @review_checks ||= {}
        checks.each do |check|
          (check.interesting_prepare_nodes || []).each do |node|
            @prepare_checks[node] ||= []
            @prepare_checks[node] << check
            @prepare_checks[node].uniq!
          end
          (check.interesting_review_nodes || []).each do |node|
            @review_checks[node] ||= []
            @review_checks[node] << check
            @review_checks[node].uniq!
          end
        end
      end

      [:prepare, :review].each do |process|
        class_eval <<-EOS
          def #{process}(node)
            checks = @#{process}_checks[node.node_type]
            checks.each {|check| check.#{process}_node_start(node) if node.file =~ check.interesting_#{process}_files} unless checks.nil?
            node.visitable_children.each {|sexp| sexp.#{process}(self)}
            checks.each {|check| check.#{process}_node_end(node) if node.file =~ check.interesting_#{process}_files} unless checks.nil?
          end
        EOS
      end
    end
  end
end
