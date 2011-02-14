require 'spec_helper'

describe RailsBestPractices::Prepares::MailerPrepare do
  before :each do
    @runner = RailsBestPractices::Core::Runner.new(:prepares => RailsBestPractices::Prepares::MailerPrepare.new)
  end

  it "should parse mailer names" do
    content =<<-EOF
    class ProjectMailer < ActionMailer::Base
    end
    EOF
    @runner.prepare('app/mailers/project_mailer.rb', content)
    RailsBestPractices::Prepares.mailer_names.should == [:ProjectMailer]
  end
end
