require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe UseMultipartAlternativeAsContentTypeOfEmailReview do
      let(:runner) { Core::Runner.new(reviews: UseMultipartAlternativeAsContentTypeOfEmailReview.new) }

      before(:each) { Core::Runner.stub!(:base_path).and_return(".") }

      def mock_email_files(entry_files, options={})
        Dir.stub!(:entries).with("./app/views/project_mailer").and_return(entry_files)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.erb").and_return(options["text.plain.erb"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.erb").and_return(options["text.html.erb"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.erb").and_return(options["text.erb"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.erb").and_return(options["html.erb"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.haml").and_return(options["text.plain.haml"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.haml").and_return(options["text.html.haml"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.haml").and_return(options["text.haml"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.haml").and_return(options["html.haml"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.slim").and_return(options["text.plain.slim"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.slim").and_return(options["text.html.slim"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.slim").and_return(options["text.slim"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.html.slim").and_return(options["html.slim"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.plain.rhtml").and_return(options["text.plain.rhtml"] || false)
        File.stub!(:exist?).with("./app/views/project_mailer/send_email.text.html.rhtml").and_return(options["text.html.rhtml"] || false)
      end

      context "rails2" do
        context "project_mailer" do
          let(:content) {
            <<-EOF
            class ProjectMailer < ActionMailer::Base
              def send_email(email)
                receiver      email.receiver
                from          email.from
                recipients    email.recipients
                sent_on       Time.now
                body          email: email
              end
            end
            EOF
          }

          context "erb" do
            it "should use mulipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.html.erb"], "text.html.erb" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(1).errors
              runner.errors[0].to_s.should == "app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email"
            end

            it "should not use multipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.html.erb"], "text.plain.erb" => true, "text.html.erb" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end

            it "should not use multiple/alternative as content_type of email when only plain text" do
              mock_email_files(["send_email.text.plain.erb"], "text.plain.erb" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end
          end

          context "haml" do
            it "should use mulipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.html.haml"], "text.html.haml" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(1).errors
              runner.errors[0].to_s.should == "app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email"
            end

            it "should not use multipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.html.haml"], "text.plain.haml" => true, "text.html.haml" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end

            it "should not use multiple/alternative as content_type of email when only plain text" do
              mock_email_files(["send_email.text.plain.haml"], "text.plain.haml" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end
          end

          context "slim" do
            it "should use mulipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.html.slim"], "text.html.slim" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(1).errors
              runner.errors[0].to_s.should == "app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email"
            end

            it "should not use multipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.html.slim"], "text.plain.slim" => true, "text.html.slim" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end

            it "should not use multiple/alternative as content_type of email when only plain text" do
              mock_email_files(["send_email.text.plain.slim"], "text.plain.slim" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end
          end

          context "rhtml" do
            it "should use mulipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.html.rhtml"], "text.html.rhtml" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(1).errors
              runner.errors[0].to_s.should == "app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email"
            end

            it "should not use multipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.html.rhtml"], "text.plain.rhtml" => true, "text.html.rhtml" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end

            it "should not use multiple/alternative as content_type of email when only plain text" do
              mock_email_files(["send_email.text.plain.rhtml"], "text.plain.rhtml" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end
          end
        end

        it "should not use mulipart/alternative as content_type of email for non deliver method" do
          content =<<-EOF
          class ProjectMailer < ActionMailer::Base
            def no_deliver
            end
          end
          EOF
          mock_email_files(["send_email.text.html.erb"])
          runner.review('app/mailers/project_mailer.rb', content)
          runner.should have(0).errors
        end
      end

      context "rails3" do
        context "project_mailer" do
          let(:content) {
            <<-EOF
            class ProjectMailer < ActionMailer::Base
              def send_email(email)
                receiver      email.receiver
                from          email.from
                recipients    email.recipients
                sent_on       Time.now
                body          email: email
              end
            end
            EOF
          }

          context "erb" do
            it "should use mulipart/alternative as content_type of email" do
              mock_email_files(["send_email.html.erb"], "html.erb" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(1).errors
              runner.errors[0].to_s.should == "app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email"
            end

            it "should not use multipart/alternative as content_type of email" do
              mock_email_files(["send_email.html.erb"], "text.erb" => true, "html.erb" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end

            it "should not use multiple/alternative as content_type of email when only plain text" do
              mock_email_files(["send_email.text.erb"], "text.erb" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end
          end

          context "haml" do
            it "should use mulipart/alternative as content_type of email" do
              mock_email_files(["send_email.html.haml"], "html.haml" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(1).errors
              runner.errors[0].to_s.should == "app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email"
            end

            it "should not use multipart/alternative as content_type of email" do
              mock_email_files(["send_email.html.haml", "send_email.text.haml"], "html.haml" => true, "text.haml" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end

            it "should not use multiple/alternative as content_type of email when only plain text" do
              mock_email_files(["send_email.text.haml"], "text.haml" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end
          end

          context "haml/erb mix" do
            it "should not suggest using multipart/alternative when mixing html.haml and text.erb" do
              mock_email_files(["send_email.html.haml", "send_email.text.erb"], "html.haml" => true, "text.erb" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors

              mock_email_files(["send_email.html.erb", "send_email.text.haml"], "html.erb" => true, "text.haml" => true)
              runner.review('app/mailers/project_mailer.rb', content)
              runner.should have(0).errors
            end
          end
        end
      end
    end
  end
end
