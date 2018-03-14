# frozen_string_literal: true

module RailsBestPractices
  module Reviews
    # Make sure to use observer (sorry we only check the mailer deliver now).
    #
    # See the best practice details here https://rails-bestpractices.com/posts/2010/07/24/use-observer/
    #
    # TODO: we need a better solution, any suggestion?
    #
    # Implementation:
    #
    # Review process:
    #   check all command nodes to see if they are callback definitions, like after_create, before_destroy,
    #   if so, remember the callback methods.
    #
    #   check all method define nodes to see
    #   if the method is a callback method,
    #   and there is a mailer deliver call,
    #   then the method should be replaced by using observer.
    class UseObserverReview < Review
      interesting_nodes :def, :command
      interesting_files MODEL_FILES
      url 'https://rails-bestpractices.com/posts/2010/07/24/use-observer/'

      def initialize(options = {})
        super
        @callbacks = []
      end

      # check a command node.
      #
      # if it is a callback definition,
      # then remember its callback methods.
      add_callback :start_command do |node|
        remember_callback(node)
      end

      # check a method define node in prepare process.
      #
      # if it is callback method,
      # and there is a actionmailer deliver call in the method define node,
      # then it should be replaced by using observer.
      add_callback :start_def do |node|
        if callback_method?(node) && deliver_mailer?(node)
          add_error 'use observer'
        end
      end

      private

        # check a command node, if it is a callback definition, such as after_create, before_create,
        # then save the callback methods in @callbacks
        def remember_callback(node)
          if node.message.to_s =~ /^after_|^before_/
            node.arguments.all.each do |argument|
              # ignore callback like after_create Comment.new
              @callbacks << argument.to_s if :symbol_literal == argument.sexp_type
            end
          end
        end

        # check a defn node to see if the method name exists in the @callbacks.
        def callback_method?(node)
          @callbacks.find { |callback| callback == node.method_name.to_s }
        end

        # check a def node to see if it contains a actionmailer deliver call.
        #
        # if the message of call node is deliver,
        # and the receiver of the call node is with receiver node who exists in @callbacks,
        # then the call node is actionmailer deliver call.
        def deliver_mailer?(node)
          node.grep_nodes(sexp_type: :call) do |child_node|
            if 'deliver' == child_node.message.to_s
              if :method_add_arg == child_node.receiver.sexp_type &&
                mailers.include?(child_node.receiver[1].receiver.to_s)
                return true
              end
            end
          end
          false
        end

        def mailers
          @mailers ||= Prepares.mailers
        end
    end
  end
end
