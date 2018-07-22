# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Review to make sure not to avoid the law of demeter.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/07/24/the-law-of-demeter/
    #
    # Implementation:
    #
    # Review process:
    #   check all method calls to see if there is method call to the association object.
    #   if there is a call node whose receiver is an object of model (compare by name),
    #   and whose message is an association of that model (also compare by name),
    #   and outer the call node, it is also a call node,
    #   then it violate the law of demeter.
    class LawOfDemeterReview < Review
      interesting_nodes :call
      interesting_files ALL_FILES
      url 'https://rails-bestpractices.com/posts/2010/07/24/the-law-of-demeter/'

      ASSOCIATION_METHODS = %w[belongs_to has_one].freeze

      # check the call node,
      #
      # if the receiver of the call node is also a call node,
      # and the receiver of the receiver call node matchs one of the class names,
      # and the message of the receiver call node matchs one of the association name with the class name,
      # then it violates the law of demeter.
      add_callback :start_call do |node|
        if :call == node.receiver.sexp_type && need_delegate?(node)
          add_error 'law of demeter'
        end
      end

      private

        # check if the call node can use delegate to avoid violating law of demeter.
        #
        # if the receiver of receiver of the call node matchs any in model names,
        # and the message of receiver of the call node matchs any in association names,
        # then it needs delegate.
      def need_delegate?(node)
        return unless variable(node)
        class_name = variable(node).to_s.sub('@', '').classify
        association_name = node.receiver.message.to_s
        association = model_associations.get_association(class_name, association_name)
        attribute_name = node.message.to_s
        association && ASSOCIATION_METHODS.include?(association['meta']) &&
          is_association_attribute?(association['class_name'], association_name, attribute_name)
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
