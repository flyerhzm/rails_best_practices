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
    # Review process:
    #   check all method calls to see if there is method call to the association object.
    #   if there is a call node whose subject is an object of model (compare by name),
    #   and whose message is an association of that model (also compare by name),
    #   and outer the call node, it is also a call node,
    #   then it violate the law of demeter.
    class LawOfDemeterReview < Review
      ASSOCIATION_METHODS = %w(belongs_to has_one)

      def url
        "http://rails-bestpractices.com/posts/15-the-law-of-demeter"
      end

      def interesting_nodes
        [:call]
      end

      # check the call node,
      #
      # if the subject of the call node is also a call node,
      # and the subject of the subject call node matchs one of the class names,
      # and the message of the subject call node matchs one of the association name with the class name,
      # then it violates the law of demeter.
      def start_call(node)
        if :call == node.subject.sexp_type && need_delegate?(node)
          add_error "law of demeter"
        end
      end

      private
        # check if the call node can use delegate to avoid violating law of demeter.
        #
        # if the subject of subject of the call node matchs any in model names,
        # and the message of subject of the call node matchs any in association names,
        # then it needs delegate.
        def need_delegate?(node)
          return unless variable(node)
          class_name = variable(node).to_s.sub('@', '').classify
          association_name = node.subject.message.to_s
          association = model_associations.get_association(class_name, association_name)
          attribute_name = node.message.to_s
          association && ASSOCIATION_METHODS.include?(association["meta"]) &&
            is_association_attribute?(association["class_name"], association_name, attribute_name)
        end

        def is_association_attribute?(association_class, association_name, attribute_name)
          if association_name =~ /able$/
            models.each do |class_name|
              if model_associations.is_association?(class_name, association_name.sub(/able$/, '')) ||
                model_associations.is_association?(class_name, association_name.sub(/able$/, 's'))
                return true if model_attributes.is_attribute?(class_name, attribute_name)
              end
            end
          else
            model_attributes.is_attribute?(association_class, attribute_name)
          end
        end
    end
  end
end
