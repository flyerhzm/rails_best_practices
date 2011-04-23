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
        @mailers = Core::Mailers.new
      end

      # check class node.
      #
      # if it is a subclass of ActionMailer::Base,
      # then remember its class name.
      def start_class(class_node)
        if s(:colon2, s(:const, :ActionMailer), :Base) == class_node.base_class
          @mailers << class_node.class_name.to_s
          Prepares.mailers = @mailers
        end
      end
    end
  end
end
