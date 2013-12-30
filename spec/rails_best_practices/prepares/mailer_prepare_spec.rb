require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe MailerPrepare do
      let(:runner) { Core::Runner.new(prepares: MailerPrepare.new) }

      it "should parse mailer names" do
        content =<<-EOF
        class ProjectMailer < ActionMailer::Base
        end
        EOF
        runner.prepare('app/mailers/project_mailer.rb', content)
        expect(Prepares.mailers.map(&:to_s)).to eq(["ProjectMailer"])
      end
    end
  end
end
