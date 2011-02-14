# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # review a controller file to make sure to use model association instead of foreign key id assignment.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/2-use-model-association.
    #
    # Implementation:
    #
    # Review process:
    #   review model define nodes in all controller files,
    #   if there is an attribute assignment node with message xxx_id=,
    #   and after it, there is a call node with message :save or :save!,
    #   and the subjects of attribute assignment node and call node are the same,
    #   then model association should be used instead of xxx_id assignment.
    class UseModelAssociationReview < Review
      def url
        "http://rails-bestpractices.com/posts/2-use-model-association"
      end

      def interesting_review_nodes
        [:defn]
      end

      def interesting_review_files
        CONTROLLER_FILES
      end

      # review method define nodes to see if there are some attribute assignments that can use model association instead in review process.
      #
      # it will review attribute assignment node with message xxx_id=, and call node with message :save or :save!
      #
      # 1. if there is an attribute assignment node with message xxx_id=,
      #    then remember the subject of attribute assignment node.
      # 2. after assignment, if there is a call node with message :save or :save!,
      #    and the subject of call node is one of the subject of attribute assignment node,
      #    then the attribute assignment should be replaced by using model association.
      def review_start_defn(node)
        @attrasgns = {}
        node.recursive_children do |child|
          case child.node_type
          when :attrasgn
            attribute_assignment(child)
          when :call
            call_assignment(child)
          else
          end
        end
        @attrasgns = nil
      end

      private
        # review an attribute assignment node, if its message is xxx_id, like
        #
        #     s(:attrasgn, s(:ivar, :@post), :user_id=,
        #       s(:arglist,
        #         s(:call, s(:call, nil, :current_user, s(:arglist)), :id, s(:arglist))
        #       )
        #     )
        #
        # then remember the subject of the attribute assignment in @attrasgns.
        #
        #     @attrasgns => { s(:ivar, :@post) => true }
        def attribute_assignment(node)
          if node.message.to_s =~ /_id=$/
            subject = node.subject
            @attrasgns[subject] = true
          end
        end

        # review a call node with message :save or :save!,
        # if the subject of call node exists in @attrasgns, like
        #
        #     s(:call, s(:ivar, :@post), :save, s(:arglist))
        #
        # then the attribute assignment should be replaced by using model association.
        def call_assignment(node)
          if [:save, :save!].include? node.message
            subject = node.subject
            add_error "use model association (for #{subject})" if @attrasgns[subject]
          end
        end
    end
  end
end
