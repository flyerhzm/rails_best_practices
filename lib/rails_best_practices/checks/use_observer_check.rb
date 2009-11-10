require 'rails_best_practices/checks/check'

module RailsBestPractices
  module Checks
    # Check a model file to make sure mail deliver method is in observer not callback.
    #
    # Implementation: 
    # Record :after_create callback
    # Check method define, if it is a callback and call deliver_xxx message in method body, then it should use observer.
    class UseObserverCheck < Check

      def interesting_nodes
        [:defn, :call]
      end

      def interesting_files
        MODLE_FILES
      end

      def initialize
        super
        @callbacks = []
      end

      def evaluate_start(node)
        if :after_create == node.message
          remember_callbacks(node)
        elsif :defn == node.node_type and @callbacks.include?(node.message_name.to_s)
          add_error "use observer" if use_observer?(node)
        end
      end

      private

      def remember_callbacks(node)
        node.arguments[1..-1].each do |argument|
          @callbacks << argument.to_ruby_string
        end
      end

      def use_observer?(node)
        node.recursive_children do |child|
          return true if :call == child.node_type and :const == child.subject.node_type and child.message.to_s =~ /^deliver_/
        end
        false
      end
    end
  end
end
