# encoding: utf-8
require 'rails_best_practices/prepares/model_prepare'
require 'rails_best_practices/prepares/mailer_prepare'
require 'rails_best_practices/prepares/schema_prepare'

module RailsBestPractices
  module Prepares
    class <<self
      attr_accessor :models, :model_associations, :model_attributes, :mailer_names
    end
  end
end
