# encoding: utf-8
module RailsBestPractices
  module Core
    # CheckingVisitor is a visitor class.
    #
    # it remembers all the checks for prepare and review processes according to interesting_prepare_nodes and interesting_review_nodes,
    # then recursively iterate all sexp nodes,
    #
    # for prepare process
    # if the node_type and the node filename match the interesting_prepare_nodes and interesting_prepare_files,
    # then run the prepare for that node.
    #
    # for review process
    # if the node_type and the node filename match the interesting_review_nodes and interesting_review_files,
    # then run the reivew for that node.
    class CheckingVisitor
      # remember all the checks for prepare and review processes according to interesting_prepare_nodes and interesting_review_nodes,
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

      # for prepare process
      # if the node_type and the node filename match the interesting_prepare_nodes and interesting_prepare_files,
      # then run the prepare for that node.
      #
      # for review process
      # if the node_type and the node filename match the interesting_review_nodes and interesting_review_files,
      # then run the reivew for that node.
      [:prepare, :review].each do |process|
        class_eval <<-EOS
          def #{process}(node)
            checks = @#{process}_checks[node.node_type]
            checks.each {|check| check.#{process}_node_start(node) if node.file =~ check.interesting_#{process}_files} unless checks.nil?
            node.children.each {|sexp| sexp.#{process}(self)}
            checks.each {|check| check.#{process}_node_end(node) if node.file =~ check.interesting_#{process}_files} unless checks.nil?
          end
        EOS
      end
    end
  end
end
