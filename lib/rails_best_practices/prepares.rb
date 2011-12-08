# encoding: utf-8
require 'rails_best_practices/prepares/model_prepare'
require 'rails_best_practices/prepares/mailer_prepare'
require 'rails_best_practices/prepares/schema_prepare'
require 'rails_best_practices/prepares/controller_prepare'
require 'rails_best_practices/prepares/route_prepare'
require 'rails_best_practices/prepares/helper_prepare'

module RailsBestPractices
  module Prepares
    class <<self
      def klasses
        models + mailers + controllers
      end

      def models
        @models ||= Core::Models.new
      end

      def model_associations
        @model_associations ||= Core::ModelAssociations.new
      end

      def model_attributes
        @model_attributes ||= Core::ModelAttributes.new
      end

      def model_methods
        @model_methods ||= Core::Methods.new
      end

      def mailers
        @mailers ||= Core::Mailers.new
      end

      def controllers
        @controllers ||= Core::Controllers.new
      end

      def controller_methods
        @controller_methods ||= Core::Methods.new
      end

      def helper_methods
        @helper_methods ||= Core::Methods.new
      end

      def routes
        @routes ||= Core::Routes.new
      end

      # Clear all prepare objects.
      def clear
        instance_variables.each do |instance_variable|
          instance_variable_set(instance_variable, nil)
        end
      end
    end
  end
end
