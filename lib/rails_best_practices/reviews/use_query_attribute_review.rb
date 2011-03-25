# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Make sure to use query attribute instead of nil?, blank? and present?.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/56-use-query-attribute.
    #
    # Implementation:
    #
    # Review process:
    #   check all method calls within conditional statements, like @user.login.nil?
    #   if their subjects are one of the model names
    #   and their messages of first call are not pluralize and not in any of the association names
    #   and their messages of second call are one of nil?, blank?, present?, or they are == ""
    #   then you can use query attribute instead.
    class UseQueryAttributeReview < Review

      QUERY_METHODS = [:nil?, :blank?, :present?]

      def url
        "http://rails-bestpractices.com/posts/56-use-query-attribute"
      end

      def interesting_nodes
        [:if]
      end

      # check if node to see whose conditional statement nodes contain nodes that can use query attribute instead.
      #
      # it will check every call nodes in the if nodes. If the call node is
      #
      # 1. two method calls, like @user.login.nil?
      # 2. the subject is one of the model names
      # 3. the message of first call is the model's attribute,
      #    the message is not in any of associations name and is not pluralize
      # 4. the message of second call is one of nil?, blank? or present? or
      #    the message is == and the argument is ""
      #
      # then the call node can use query attribute instead.
      def start_if(node)
        if node = query_attribute_node(node.conditional_statement)
          subject_node = node.subject
          add_error "use query attribute (#{subject_node.subject}.#{subject_node.message}?)", node.file, node.line
        end
      end

      private
        # recursively check conditional statement nodes to see if there is a call node that may be possible query attribute.
        def query_attribute_node(conditional_statement_node)
          case conditional_statement_node.node_type
          when :and, :or
            return query_attribute_node(conditional_statement_node[1]) || query_attribute_node(conditional_statement_node[2])
          when :not
            return query_attribute_node(conditional_statement_node[1])
          when :call
            return conditional_statement_node if possible_query_attribute?(conditional_statement_node)
          end
          nil
        end

        # check if the node may use query attribute instead.
        #
        # if the node contains two method calls, e.g. @user.login.nil?
        #
        # for the first call, the subject should be one of the class names and
        # the message should be one of the attribute name.
        #
        # for the second call, the message should be one of nil?, blank? or present? or
        # it is compared with an empty string.
        #
        # the node that may use query attribute is like
        #
        #     s(:call, s(:call, s(:ivar, :@user), :login, s(:arglist)), :nil?, s(:arglist))
        #
        #
        def possible_query_attribute?(node)
          return false unless :call == node.subject.node_type
          subject = node.subject.subject
          return false unless subject
          message = node.subject.message

          [:arglist] == node.subject.arguments && is_model?(subject) && model_attribute?(subject, message) &&
            (QUERY_METHODS.include?(node.message) || compare_with_empty_string?(node))
        end

        # check if the subject is one of the models.
        #
        #     subject, subject of call node, like
        #         s(:ivar, @user)
        def is_model?(subject)
          return false if :const == subject.node_type
          class_name = subject.to_s(:remove_at => true).classify
          models.include?(class_name)
        end

        # check if the subject and message is one of the model's attribute.
        # the subject should match one of the class model name, and the message should match one of attribute name.
        #
        #     subject, subject of call node, like
        #         s(:ivar, @user)
        #
        #     message, message of call node, like
        #         :login
        def model_attribute?(subject, message)
          class_name = subject.to_s(:remove_at => true).classify
          attribute_type = model_attributes.get_attribute_type(class_name, message.to_s)
          attribute_type && ![:integer, :float].include?(attribute_type)
        end

        # check if the node is with node type :call, node message :== and node arguments {:arglist, (:str, "")}
        #
        #     @user.login == "" => true
        def compare_with_empty_string?(node)
          :call == node.node_type && :== == node.message && [:arglist, [:str, ""]] == node.arguments
        end
    end
  end
end
