# encoding: utf-8
module RailsBestPractices
  module Prepares
    # Remember the mailer names.
    class MailerPrepare < Core::Check
      include Core::Check::Classable

      interesting_nodes :class
      interesting_files MAILER_FILES, MODEL_FILES

      def initialize
        @mailers = Prepares.mailers
      end

      # check class node.
      #
      # if it is a subclass of ActionMailer::Base,
      # then remember its class name.
      add_callback :start_class do |node|
        if "ActionMailer::Base" == current_extend_class_name
          @mailers << @klass
        end
      end
    end
  end
end
