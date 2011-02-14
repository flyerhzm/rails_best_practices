# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remember the mailer names.
    class MailerPrepare < Core::Check

      def interesting_nodes
        [:class]
      end

      def interesting_files
        /#{MAILER_FILES}|#{MODEL_FILES}/
      end

      def initialize
        @mailer_names = []
      end

      # check class node.
      #
      # if it is a subclass of ActionMailer::Base,
      # then remember its class name.
      def start_class(class_node)
        if s(:colon2, s(:const, :ActionMailer), :Base) == class_node.base_class
          @mailer_names << class_node.class_name
          Prepares.mailer_names = @mailer_names
        end
      end
    end
  end
end
