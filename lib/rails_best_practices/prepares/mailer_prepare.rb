# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remember the mailer names.
    class MailerPrepare < Core::Check
      include Core::Check::Classable

      def interesting_nodes
        [:class, :module]
      end

      def interesting_files
        /#{MAILER_FILES}|#{MODEL_FILES}/
      end

      def initialize
        @mailers = Prepares.mailers
      end

      # check class node.
      #
      # if it is a subclass of ActionMailer::Base,
      # then remember its class name.
      def start_class(node)
        if "ActionMailer::Base" == node.base_class.to_s
          @mailers << class_name(node)
        end
      end
    end
  end
end
