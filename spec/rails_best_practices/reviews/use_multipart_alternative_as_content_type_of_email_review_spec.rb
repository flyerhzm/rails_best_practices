# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe UseMultipartAlternativeAsContentTypeOfEmailReview do
      let(:runner) { Core::Runner.new(prepares: Prepares::GemfilePrepare.new, reviews: described_class.new) }

      before { allow(Core::Runner).to receive(:base_path).and_return('.') }

      def mock_email_files(entry_files)
        allow(Dir).to receive(:entries).with('./app/views/project_mailer').and_return(entry_files)
      end

      before do
        content = <<~EOF
          GEM
            remote: https://rubygems.org
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

      context 'project_mailer' do
        let(:content) do
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
        end

        context 'erb' do
          it 'uses mulipart/alternative as content_type of email' do
            mock_email_files(['send_email.html.erb'])
            runner.review('app/mailers/project_mailer.rb', content)
            expect(runner.errors.size).to eq(1)
            expect(runner.errors[0].to_s).to eq(
              'app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email'
            )
          end

          it 'does not use multiple/alternative as content_type of email when only plain text' do
            mock_email_files(['send_email.text.erb'])
            runner.review('app/mailers/project_mailer.rb', content)
            expect(runner.errors.size).to eq(0)
          end

          it 'does not use multipart/alternative as content_type of email' do
            mock_email_files(['send_email.text.erb', 'send_email.html.erb'])
            runner.review('app/mailers/project_mailer.rb', content)
            expect(runner.errors.size).to eq(0)
          end
        end

        context 'haml' do
          it 'uses mulipart/alternative as content_type of email' do
            mock_email_files(['send_email.html.haml'])
            runner.review('app/mailers/project_mailer.rb', content)
            expect(runner.errors.size).to eq(1)
            expect(runner.errors[0].to_s).to eq(
              'app/mailers/project_mailer.rb:2 - use multipart/alternative as content_type of email'
            )
          end

          it 'does not use multiple/alternative as content_type of email when only plain text' do
            mock_email_files(['send_email.text.haml'])
            runner.review('app/mailers/project_mailer.rb', content)
            expect(runner.errors.size).to eq(0)
          end

          it 'does not use multipart/alternative as content_type of email' do
            mock_email_files(['send_email.html.haml', 'send_email.text.haml'])
            runner.review('app/mailers/project_mailer.rb', content)
            expect(runner.errors.size).to eq(0)
          end

          it 'does not use multipart/alternative as content_type of email with text locale' do
            mock_email_files(['send_email.html.haml', 'send_email.de.text.haml'])
            runner.review('app/mailers/project_mailer.rb', content)
            expect(runner.errors.size).to eq(0)
          end

          it 'does not use multipart/alternative as content_type of email with html locale' do
            mock_email_files(['send_email.de.html.haml', 'send_email.text.haml'])
            runner.review('app/mailers/project_mailer.rb', content)
            expect(runner.errors.size).to eq(0)
          end
        end

        context 'haml/erb mix' do
          it 'does not suggest using multipart/alternative when mixing html.haml and text.erb' do
            mock_email_files(['send_email.html.haml', 'send_email.text.erb'])
            runner.review('app/mailers/project_mailer.rb', content)
            expect(runner.errors.size).to eq(0)

            mock_email_files(['send_email.html.erb', 'send_email.text.haml'])
            runner.review('app/mailers/project_mailer.rb', content)
            expect(runner.errors.size).to eq(0)
          end
        end

        it 'does not check ignored files' do
          runner = Core::Runner.new(reviews: described_class.new(ignored_files: /project_mailer/))
          mock_email_files(['send_email.html.haml'])
          runner.review('app/mailers/project_mailer.rb', content)
          expect(runner.errors.size).to eq(0)
        end
      end
    end
  end
end
