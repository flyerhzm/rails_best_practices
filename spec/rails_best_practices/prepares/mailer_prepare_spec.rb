require 'spec_helper'

describe RailsBestPractices::Prepares::MailerPrepare do
  let(:runner) { RailsBestPractices::Core::Runner.new(:prepares => RailsBestPractices::Prepares::MailerPrepare.new) }

  it "should parse mailer names" do
    content =<<-EOF
    class ProjectMailer < ActionMailer::Base
    end
    EOF
    runner.prepare('app/mailers/project_mailer.rb', content)
    RailsBestPractices::Prepares.mailers.should == ["ProjectMailer"]
  end
end
