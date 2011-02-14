# encoding: utf-8
require 'rails_best_practices/prepares/model_prepare'
require 'rails_best_practices/prepares/mailer_prepare'

module RailsBestPractices
  module Prepares
    class <<self
      attr_accessor :model_associations, :mailer_names
    end
  end
end
