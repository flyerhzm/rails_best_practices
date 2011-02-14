# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Make sure to add a model virual attribute to simplify model creation.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/4-add-model-virtual-attribute
    #
    # Implementation:
    #
    # Review process:
    #   check method define nodes in all controller files,
    #   if there are more than one [] method calls with the same subject and arguments,
    #   but assigned to one model's different attribute.
    #   and after these method calls, there is a save method call for that model, like
    #
    #       def create
    #         @user = User.new(params[:user])
    #         @user.first_name = params[:full_name].split(' ', 2).first
    #         @user.last_name = params[:full_name].split(' ', 2).last
    #         @user.save
    #       end
    #
    #   then the model needs to add a virtual attribute.
    class AddModelVirtualAttributeReview < Review
      def url
        "http://rails-bestpractices.com/posts/4-add-model-virtual-attribute"
      end

      def interesting_nodes
        [:defn]
      end

      def interesting_files
        CONTROLLER_FILES
      end

      # check method define nodes to see if there are some attribute assignments that can use model virtual attribute instead in review process.
      #
      # it will check every attribute assignment nodes and call node of message :save or :save!, if
      #
      # 1. there are more than one arguments who contain call node with messages :[] in attribute assignment nodes, e.g.
      #     @user.first_name = params[:full_name].split(' ').first
      #     @user.last_name = params[:full_name].split(' ').last
      # 2. the messages of attribute assignment nodes housld be different (:first_name= , :last_name=)
      # 3. the argument of call nodes with message :[] should be same (:full_name)
      # 4. there should be a call node with message :save or :save! after attribute assignment nodes
      #     @user.save
      # 5. and the subject of save or save! call node should be the same with the subject of attribute assignment nodes
      #
      # then the attribute assignment nodes can add model virtual attribute instead.
      def start_defn(node)
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
      end

      private
        # check an attribute assignment node, if there is a :[] message of call node in the attribute assignment node,
        # then remember this attribute assignment.
        #
        #     s(:attrasgn, s(:ivar, :@user), :first_name=,
        #       s(:arglist,
        #         s(:call,
        #           s(:call,
        #             s(:call, s(:call, nil, :params, s(:arglist)), :[], s(:arglist, s(:lit, :full_name))),
        #             :split,
        #             s(:arglist, s(:str, " "), s(:lit, 2))
        #           ),
        #           :first,
        #           s(:arglist)
        #         )
        #       )
        #     )
        #
        # The remember attribute assignments (@attrasgns) are as follows
        #
        #     {
        #       s(:ivar, :@user) =>
        #         [{
        #           :message=>:first_name=,
        #           :arguments=>s(:call, s(:call, nil, :params, s(:arglist)), :[], s(:arglist, s(:lit, :full_name)))
        #         }]
        #     }
        def attribute_assignment(node)
          subject = node.subject
          arguments_node = node.arguments.grep_node(:message => :[])
          return if subject.nil? or arguments_node.nil?
          @attrasgns[subject] ||= []
          @attrasgns[subject] << {:message => node.message, :arguments => arguments_node}
        end

        # check a call node with message :save or :save!,
        # if there exists an attribute assignment for the subject of this call node,
        # and if the arguments of this attribute assignments has duplicated entries (different message and same arguments),
        # then this node needs to add a virtual attribute.
        #
        # e.g. this is @attrasgns
        #     {
        #       s(:ivar, :@user)=>
        #         [{
        #           :message=>:first_name=,
        #           :arguments=>s(:call, s(:call, nil, :params, s(:arglist)), :[], s(:arglist, s(:lit, :full_name)))
        #         }, {
        #           :message=>:last_name=,
        #           :arguments=>s(:call, s(:call, nil, :params, s(:arglist)), :[], s(:arglist, s(:lit, :full_name)))
        #         }]
        #     }
        # and this is the call node
        #     s(:call, s(:ivar, :@user), :save, s(:arglist))
        #
        # The message of call node is :save,
        # and the key of @attrasgns is the same as the subject of call node,
        # and the value of @aatrasgns has different message and same arguments.
        def call_assignment(node)
          if [:save, :save!].include? node.message
            subject = node.subject
            add_error "add model virtual attribute (for #{subject})" if params_dup?(@attrasgns[subject].collect {|h| h[:arguments]})
          end
        end

        # if the nodes are duplicated.
        def params_dup?(nodes)
          return false if nodes.nil?
          !nodes.dups.empty?
        end
    end
  end
end
