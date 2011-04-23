# encoding: utf-8
require 'rails_best_practices/prepares/model_prepare'
require 'rails_best_practices/prepares/mailer_prepare'
require 'rails_best_practices/prepares/schema_prepare'

module RailsBestPractices
  module Prepares
    class <<self
      attr_writer :models, :model_associations, :model_attributes, :mailers

      def models
        @models ||= Core::Models.new
      end

      def model_associations
        @model_associations ||= Core::ModelAssociations.new
      end

      def model_attributes
        @model_attributes ||= Core::ModelAttributes.new
      end

      def mailers
        @mailers ||= Core::Mailers.new
      end
    end
  end
end
