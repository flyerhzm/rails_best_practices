require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe NotUseDefaultRouteReview do
      let(:runner) { Core::Runner.new(reviews: NotUseDefaultRouteReview.new) }

      describe "rails2" do
        it "should not use default route" do
          content = <<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.resources :posts, member: { push: :post }

            map.connect ':controller/:action/:id'
            map.connect ':controller/:action/:id.:format'
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(2).errors
          runner.errors[0].to_s.should == "config/routes.rb:4 - not use default route"
          runner.errors[1].to_s.should == "config/routes.rb:5 - not use default route"
        end

        it "should no not use default route" do
          content = <<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.resources :posts, member: { push: :post }
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(0).errors
        end
      end

      describe "rails3" do
        it "should not use default route" do
          content = <<-EOF
          RailsBestpracticesCom::Application.routes.draw do |map|
            resources :posts

            match ':controller(/:action(/:id(.:format)))'
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(1).errors
          runner.errors[0].to_s.should == "config/routes.rb:4 - not use default route"
        end

        it "should no not use default route" do
          content = <<-EOF
          RailsBestpracticesCom::Application.routes.draw do |map|
            resources :posts
          end
          EOF
          runner.review('config/routes.rb', content)
          runner.should have(0).errors
        end
      end
    end
  end
end
