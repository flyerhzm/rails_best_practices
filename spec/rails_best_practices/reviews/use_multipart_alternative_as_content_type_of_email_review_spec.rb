require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe UseMultipartAlternativeAsContentTypeOfEmailReview do
      let(:runner) { Core::Runner.new(prepares: Prepares::GemfilePrepare.new, reviews: UseMultipartAlternativeAsContentTypeOfEmailReview.new) }

      before(:each) { allow(Core::Runner).to receive(:base_path).and_return(".") }

      def mock_email_files(entry_files)
        allow(Dir).to receive(:entries).with("./app/views/project_mailer").and_return(entry_files)
      end

      context "rails2" do
        before do
        content = <<-EOF
GEM
  remote: http://rubygems.org
  specs:
    rails (2.3.14)
      actionmailer (= 2.3.14)
      actionpack (= 2.3.14)
      activerecord (= 2.3.14)
      activeresource (= 2.3.14)
      activesupport (= 2.3.14)
      bundler (~> 1.0)
      railties (= 2.3.14)
        EOF
        runner.prepare('Gemfile.lock', content)
        end

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
              mock_email_files(["send_email.text.html.erb"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(1)
              expect(runner.errors[0].to_s).to eq("app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email")
            end

            it "should use multiple/alternative as content_type of email when only plain text" do
              mock_email_files(["send_email.text.plain.erb"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(1)
              expect(runner.errors[0].to_s).to eq("app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email")
            end

            it "should not use multipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.plain.erb", "send_email.text.html.erb"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(0)
            end
          end

          context "haml" do
            it "should use mulipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.html.haml"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(1)
              expect(runner.errors[0].to_s).to eq("app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email")
            end

            it "should use multiple/alternative as content_type of email when only plain text" do
              mock_email_files(["send_email.text.plain.haml"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(1)
              expect(runner.errors[0].to_s).to eq("app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email")
            end

            it "should not use multipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.plain.haml", "send_email.text.html.haml"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(0)
            end
          end

          context "slim" do
            it "should use mulipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.html.slim"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(1)
              expect(runner.errors[0].to_s).to eq("app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email")
            end

            it "should use multiple/alternative as content_type of email when only plain text" do
              mock_email_files(["send_email.text.plain.slim"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(1)
              expect(runner.errors[0].to_s).to eq("app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email")
            end

            it "should not use multipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.plain.slim", "send_email.text.html.slim"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(0)
            end
          end

          context "rhtml" do
            it "should use mulipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.html.rhtml"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(1)
              expect(runner.errors[0].to_s).to eq("app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email")
            end

            it "should use multiple/alternative as content_type of email when only plain text" do
              mock_email_files(["send_email.text.plain.rhtml"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(1)
              expect(runner.errors[0].to_s).to eq("app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email")
            end

            it "should not use multipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.plain.rhtml", "send_email.text.html.rhtml"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(0)
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
          mock_email_files([])
          runner.review('app/mailers/project_mailer.rb', content)
          expect(runner.errors.size).to eq(0)
        end
      end

      context "rails3" do
        before do
        content = <<-EOF
GEM
  remote: http://rubygems.org
  specs:
    rails (3.2.13)
      actionmailer (= 3.2.13)
      actionpack (= 3.2.13)
      activerecord (= 3.2.13)
      activeresource (= 3.2.13)
      activesupport (= 3.2.13)
      bundler (~> 1.0)
      railties (= 3.2.13)
        EOF
        runner.prepare('Gemfile.lock', content)
        end

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
              mock_email_files(["send_email.html.erb"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(1)
              expect(runner.errors[0].to_s).to eq("app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email")
            end

            it "should use multiple/alternative as content_type of email when only plain text" do
              mock_email_files(["send_email.text.erb"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(1)
              expect(runner.errors[0].to_s).to eq("app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email")
            end

            it "should not use multipart/alternative as content_type of email" do
              mock_email_files(["send_email.text.erb", "send_email.html.erb"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(0)
            end
          end

          context "haml" do
            it "should use mulipart/alternative as content_type of email" do
              mock_email_files(["send_email.html.haml"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(1)
              expect(runner.errors[0].to_s).to eq("app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email")
            end

            it "should use multiple/alternative as content_type of email when only plain text" do
              mock_email_files(["send_email.text.haml"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(1)
              expect(runner.errors[0].to_s).to eq("app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email")
            end

            it "should not use multipart/alternative as content_type of email" do
              mock_email_files(["send_email.html.haml", "send_email.text.haml"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(0)
            end

            it "should not use multipart/alternative as content_type of email with text locale" do
              mock_email_files(["send_email.html.haml", "send_email.de.text.haml"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(0)
            end

            it "should not use multipart/alternative as content_type of email with html locale" do
              mock_email_files(["send_email.de.html.haml", "send_email.text.haml"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(0)
            end
          end

          context "haml/erb mix" do
            it "should not suggest using multipart/alternative when mixing html.haml and text.erb" do
              mock_email_files(["send_email.html.haml", "send_email.text.erb"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(0)

              mock_email_files(["send_email.html.erb", "send_email.text.haml"])
              runner.review('app/mailers/project_mailer.rb', content)
              expect(runner.errors.size).to eq(0)
            end
          end

          it "should not check ignored files" do
            runner = Core::Runner.new(reviews: UseMultipartAlternativeAsContentTypeOfEmailReview.new(ignored_files: /project_mailer/))
            mock_email_files(["send_email.html.haml"])
            runner.review('app/mailers/project_mailer.rb', content)
            expect(runner.errors.size).to eq(0)
          end
        end
      end
    end
  end
end
