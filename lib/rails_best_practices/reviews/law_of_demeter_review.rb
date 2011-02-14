# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review to make sure not to avoid the law of demeter.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/15-the-law-of-demeter.
    #
    # Implementation:
    #
    # Prepare process:
    #   only review all model files to save model names and association names.
    #
    # Review process:
    #   review all method calls to see if there is method call to the association object.
    #   if there is a call node whose subject is an object of model (compare by name),
    #   and whose message is an association of that model (also compare by name),
    #   and outer the call node, it is also a call node,
    #   then it violate the law of demeter.
    class LawOfDemeterReview < Review

      prepare_model_associations

      def url
        "http://rails-bestpractices.com/posts/15-the-law-of-demeter"
      end

      def interesting_review_nodes
        [:call]
      end

      # review the call node in review process,
      #
      # if the subject of the call node is also a call node,
      # and the subject of the subject call node matchs one of the class names,
      # and the message of the subject call node matchs one of the association name with the class name, like
      #
      #     s(:call,
      #       s(:call, s(:ivar, :@invoice), :user, s(:arglist)),
      #       :name,
      #       s(:arglist)
      #     )
      #
      # then it violates the law of demeter.
      def review_start_call(node)
        if [:lvar, :ivar].include?(node.subject.subject.node_type) && need_delegate?(node)
          add_error "law of demeter"
        end
      end

      private
        # review if the call node can use delegate to avoid violating law of demeter.
        #
        # if the subject of subject of the call node matchs any in model names,
        # and the message of subject of the call node matchs any in association names,
        # then it needs delegate.
        #
        # e.g. the source code is
        #
        #     @invoic.user.name
        #
        # then the call node is
        #
        #     s(:call, s(:call, s(:ivar, :@invoice), :user, s(:arglist)), :name, s(:arglist))
        #
        # as you see the subject of subject of the call node is [:ivar, @invoice],
        # and the message of subject of the call node is :user
        def need_delegate?(node)
          @associations.each do |class_name, associations|
            return true if equal?(node.subject.subject, class_name) && associations.find { |association| equal?(association, node.subject.message) }
          end
          false
        end

        # only review belongs_to and has_one association.
        def association_methods
          [:belongs_to, :has_one]
        end
    end
  end
end
