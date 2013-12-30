require 'spec_helper'

module RailsBestPractices
  module Reviews
    describe OveruseRouteCustomizationsReview do
      let(:runner) { Core::Runner.new(reviews: OveruseRouteCustomizationsReview.new) }

      describe "rails2" do
        it "should overuse route customizations" do
          content = <<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.resources :posts, member: { comments: :get,
                                               create_comment: :post,
                                               update_comment: :update,
                                               delete_comment: :delete }
          end
          EOF
          runner.review('config/routes.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("config/routes.rb:2 - overuse route customizations (customize_count > 3)")
        end

        it "should overuse route customizations with member" do
          content = <<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.resources :posts, member: { create_comment: :post,
                                               update_comment: :update,
                                               delete_comment: :delete,
                                               disable_comment: :post }
          end
          EOF
          runner.review('config/routes.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("config/routes.rb:2 - overuse route customizations (customize_count > 3)")
        end

        it "should overuse route customizations with collection" do
          content = <<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.resources :posts, collection: { list_comments: :get,
                                                   update_comments: :get,
                                                   delete_comments: :get,
                                                   disable_comments: :get }
          end
          EOF
          runner.review('config/routes.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("config/routes.rb:2 - overuse route customizations (customize_count > 3)")
        end

        it "should overuse route customizations with hash member and collection" do
          content = <<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.resources :categories do |category|
              category.resources :posts, member: { create_comment: :post,
                                                      update_comment: :update,
                                                      delete_comment: :delete },
                                         collection: { comments: :get }
            end
          end
          EOF
          runner.review('config/routes.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("config/routes.rb:3 - overuse route customizations (customize_count > 3)")
        end

        it "should overuse route customizations with array member and collection" do
          content = <<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.resources :categories do |category|
              category.resources :posts, member: [:create_comment, :update_comment, :delete_comment],
                                         collection: [:comments]
            end
          end
          EOF
          runner.review('config/routes.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("config/routes.rb:3 - overuse route customizations (customize_count > 3)")
        end

        it "should not overuse route customizations without customization" do
          content = <<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.resources :posts
          end
          EOF
          runner.review('config/routes.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it "should not overuse route customizations when customize route is only one" do
          content = <<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.resources :posts, member: { vote: :post }
          end
          EOF
          runner.review('config/routes.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it "should not raise error for constants in routes" do
          content =<<-EOF
          IP_PATTERN = /(((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2}))|[\d]+/.freeze
          map.resources :vlans do |vlan|
            vlan.resources :ip_ranges, member: {move: [:get, :post]} do |range|
              range.resources :ips, requirements: { id: IP_PATTERN }
            end
          end
          EOF
          runner.review('config/routes.rb', content)
          expect(runner.errors.size).to eq(0)
        end
      end

      describe "rails3" do
        it "should overuse route customizations" do
          content = <<-EOF
          RailsBestpracticesCom::Application.routes.draw do
            resources :posts do
              member do
                post :create_comment
                update :update_comment
                delete :delete_comment
              end

              collection do
                get :comments
              end
            end
          end
          EOF
          runner.review('config/routes.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("config/routes.rb:2 - overuse route customizations (customize_count > 3)")
        end

        it "should overuse route customizations another way" do
          content = <<-EOF
          RailsBestpracticesCom::Application.routes.draw do
            resources :posts do
              post :create_comment, on: :member
              update :update_comment, on: :member
              delete :delete_comment, on: :member
              get :comments, on: :collection
            end
          end
          EOF
          runner.review('config/routes.rb', content)
          expect(runner.errors.size).to eq(1)
          expect(runner.errors[0].to_s).to eq("config/routes.rb:2 - overuse route customizations (customize_count > 3)")
        end

        it "should not overuse route customizations without customization" do
          content = <<-EOF
          RailsBestpracticesCom::Application.routes.draw do
            resources :posts
          end
          EOF
          runner.review('config/routes.rb', content)
          expect(runner.errors.size).to eq(0)
        end

        it "should not overuse route customizations when customize route is only one" do
          content = <<-EOF
          RailsBestpracticesCom::Application.routes.draw do
            resources :posts do
              member do
                post :vote
              end
            end
          end
          EOF
          runner.review('config/routes.rb', content)
          expect(runner.errors.size).to eq(0)
        end
      end

      it "should not check ignored files" do
        runner = Core::Runner.new(reviews: OveruseRouteCustomizationsReview.new(ignored_files: /config\/routes\.rb/))
        content = <<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.resources :posts, member: { comments: :get,
                                               create_comment: :post,
                                               update_comment: :update,
                                               delete_comment: :delete }
          end
        EOF
        runner.review('config/routes.rb', content)
        expect(runner.errors.size).to eq(0)
      end
    end
  end
end
