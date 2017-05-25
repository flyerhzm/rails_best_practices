# encoding: utf-8
module RailsBestPractices
  module Reviews
    # Make sure to add a model virual attribute to simplify model creation.
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/07/21/add-model-virtual-attribute/
    #
    # Implementation:
    #
    # Review process:
    #   check method define nodes in all controller files,
    #   if there are more than one [] method calls with the same receiver and arguments,
    #   but assigned to one model's different attribute.
    #   and after these method calls, there is a save method call for that model,
    #   then the model needs to add a virtual attribute.
    class AddModelVirtualAttributeReview < Review
      interesting_nodes :def
      interesting_files CONTROLLER_FILES
      url "https://rails-bestpractices.com/posts/2010/07/21/add-model-virtual-attribute/"

      # check method define nodes to see if there are some attribute assignments that can use model virtual attribute instead in review process.
      #
      # it will check every attribute assignment nodes and call node of message :save or :save!, if
      #
      # 1. there are more than one arguments who contain array reference node in the right value of assignment nodes,
      # 2. the messages of attribute assignment nodes housld be different (:first_name= , :last_name=)
      # 3. the argument of call nodes with message :[] should be same (:full_name)
      # 4. there should be a call node with message :save or :save! after attribute assignment nodes
      # 5. and the receiver of save or save! call node should be the same with the receiver of attribute assignment nodes
      #
      # then the attribute assignment nodes can add model virtual attribute instead.
      add_callback :start_def do |node|
        @assignments = {}
        node.recursive_children do |child|
          case child.sexp_type
          when :assign
            assign(child)
          when :call
            call_assignment(child)
          end
        end
      end

      private

        # check an attribute assignment node, if there is a array reference node in the right value of assignment node,
        # then remember this attribute assignment.
        def assign(node)
          left_value = node.left_value
          right_value = node.right_value
          return unless :field == left_value.sexp_type && :call == right_value.sexp_type
          aref_node = right_value.grep_node(sexp_type: :aref)
          if aref_node
            assignments(left_value.receiver.to_s) << {message: left_value.message.to_s, arguments: aref_node.to_s}
          end
        end

        # check a call node with message "save" or "save!",
        # if there exists an attribute assignment for the receiver of this call node,
        # and if the arguments of this attribute assignments has duplicated entries (different message and same arguments),
        # then this node needs to add a virtual attribute.
        def call_assignment(node)
          if ["save", "save!"].include? node.message.to_s
            receiver = node.receiver.to_s
            add_error "add model virtual attribute (for #{receiver})" if params_dup?(assignments(receiver).collect {|h| h[:arguments]})
          end
        end

        # if the nodes are duplicated.
        def params_dup?(nodes)
          return false if nodes.nil?
          !dups(nodes).empty?
        end

        # get the assignments of receiver.
        def assignments(receiver)
          @assignments[receiver] ||= []
        end

        # Get the duplicate entries from an Enumerable.
        #
        # @return [Enumerable] the duplicate entries.
        def dups(nodes)
          nodes.inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
        end
    end
  end
end
