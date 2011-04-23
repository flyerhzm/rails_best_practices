# encoding: utf-8
require 'rails_best_practices/prepares/model_prepare'
require 'rails_best_practices/prepares/mailer_prepare'
require 'rails_best_practices/prepares/schema_prepare'

module RailsBestPractices
  module Prepares
    class <<self
      attr_writer :models, :model_associations, :model_attributes, :mailer_names

      [:models, :model_associations, :model_attributes, :mailer_names].each do |method_name|
        class_eval <<-EOS
        def #{method_name}
          @#{method_name} ||= []
        end
        EOS
      end
    end
  end
end
