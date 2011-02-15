require 'spec_helper'

describe RailsBestPractices::Reviews::UseMultipartAlternativeAsContentTypeOfEmailReview do
  let(:runner) { RailsBestPractices::Core::Runner.new(:reviews => RailsBestPractices::Reviews::UseMultipartAlternativeAsContentTypeOfEmailReview.new) }

  context "rails2" do
    before :each do
      RailsBestPractices::Core::Runner.stub!(:base_path).and_return(".")
    end

    it "should use mulipart/alternative as content_type of email" do
      content =<<-EOF
      class ProjectMailer < ActionMailer::Base
        def send_email(email)
          subject       email.subject
          from          email.from
          recipients    email.recipients
          sent_on       Time.now
          body          :email => email
        end
      end
      EOF
      Dir.stub!(:entries).with("./app/views/project_mailer").and_return(["send_email.html.erb"])
      runner.review('app/mailers/project_mailer.rb', content)
      runner.should have(1).errors
      runner.errors[0].to_s.should == "app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email"
    end

    it "should not use mulipart/alternative as content_type of email by erb" do
      content =<<-EOF
      class ProjectMailer < ActionMailer::Base
        def send_email(email)
          subject       email.subject
          from          email.from
          recipients    email.recipients
          sent_on       Time.now
          body          :email => email
        end
      end
      EOF
      Dir.stub!(:entries).with("./app/views/project_mailer").and_return(["send_email.html.erb"])
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.erb").and_return(true)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.erb").and_return(true)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.rhtml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.rhtml").and_return(false)
      runner.review('app/mailers/project_mailer.rb', content)
      runner.should have(0).errors
    end

    it "should not use mulipart/alternative as content_type of email by haml" do
      content =<<-EOF
      class ProjectMailer < ActionMailer::Base
        def send_email(email)
          subject       email.subject
          from          email.from
          recipients    email.recipients
          sent_on       Time.now
          body          :email => email
        end
      end
      EOF
      Dir.stub!(:entries).with("./app/views/project_mailer").and_return(["send_email.html.erb"])
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.haml").and_return(true)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.haml").and_return(true)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.rhtml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.rhtml").and_return(false)
      runner.review('app/mailers/project_mailer.rb', content)
      runner.should have(0).errors
    end

    it "should not use mulipart/alternative as content_type of email by rhtml" do
      content =<<-EOF
      class ProjectMailer < ActionMailer::Base
        def send_email(email)
          subject       email.subject
          from          email.from
          recipients    email.recipients
          sent_on       Time.now
          body          :email => email
        end
      end
      EOF
      Dir.stub!(:entries).with("./app/views/project_mailer").and_return(["send_email.html.erb"])
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.rhtml").and_return(true)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.rhtml").and_return(true)
      runner.review('app/mailers/project_mailer.rb', content)
      runner.should have(0).errors
    end

    it "should not use mulipart/alternative as content_type of email for non deliver method" do
      content =<<-EOF
      class ProjectMailer < ActionMailer::Base
        def no_deliver
        end
      end
      EOF
      Dir.stub!(:entries).with("./app/views/project_mailer").and_return(["send_email.html.erb"])
      runner.review('app/mailers/project_mailer.rb', content)
      runner.should have(0).errors
    end
  end

  context "rails3" do
    it "should use mulipart/alternative as content_type of email" do
      content =<<-EOF
      class ProjectMailer < ActionMailer::Base
        def send_email(email)
          subject       email.subject
          from          email.from
          recipients    email.recipients
          sent_on       Time.now
          body          :email => email
        end
      end
      EOF
      Dir.stub!(:entries).with("./app/views/project_mailer").and_return(["send_email.html.erb"])
      runner.review('app/mailers/project_mailer.rb', content)
      runner.should have(1).errors
      runner.errors[0].to_s.should == "app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email"
    end

    it "should not use mulipart/alternative as content_type of email by erb" do
      content =<<-EOF
      class ProjectMailer < ActionMailer::Base
        def send_email(email)
          subject       email.subject
          from          email.from
          recipients    email.recipients
          sent_on       Time.now
          body          :email => email
        end
      end
      EOF
      Dir.stub!(:entries).with("./app/views/project_mailer").and_return(["send_email.html.erb"])
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.erb").and_return(true)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.erb").and_return(true)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.rhtml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.rhtml").and_return(false)
      runner.review('app/mailers/project_mailer.rb', content)
      runner.should have(0).errors
    end

    it "should not use mulipart/alternative as content_type of email by haml" do
      content =<<-EOF
      class ProjectMailer < ActionMailer::Base
        def send_email(email)
          subject       email.subject
          from          email.from
          recipients    email.recipients
          sent_on       Time.now
          body          :email => email
        end
      end
      EOF
      Dir.stub!(:entries).with("./app/views/project_mailer").and_return(["send_email.html.erb"])
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.erb").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.haml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.haml").and_return(true)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.haml").and_return(true)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.rhtml").and_return(false)
      File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.rhtml").and_return(false)
      runner.review('app/mailers/project_mailer.rb', content)
      runner.should have(0).errors
    end
  end
end
