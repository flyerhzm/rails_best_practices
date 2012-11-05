require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe RoutePrepare do
      let(:runner) { Core::Runner.new(prepares: RoutePrepare.new) }

      context "rails2" do
        context "resources" do
          it "should add resources route" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resources :posts
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 7
            routes.map(&:to_s).should == ["PostsController#index", "PostsController#show", "PostsController#new", "PostsController#create", "PostsController#edit", "PostsController#update", "PostsController#destroy"]
          end

          it "should add multiple resources route" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resources :posts, :users
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 14
          end

          it "should add resources route with explict controller" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resources :posts, controller: :blog_posts
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 7
            routes.map(&:to_s).should == ["BlogPostsController#index", "BlogPostsController#show", "BlogPostsController#new", "BlogPostsController#create", "BlogPostsController#edit", "BlogPostsController#update", "BlogPostsController#destroy"]
          end

          it "should add resources route with only option" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resources :posts, only: [:index, :show, :new, :create]
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 4
            routes.map(&:to_s).should == ["PostsController#index", "PostsController#show", "PostsController#new", "PostsController#create"]
          end

          it "should add resources route with except option" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resources :posts, except: [:edit, :update, :destroy]
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 4
            routes.map(&:to_s).should == ["PostsController#index", "PostsController#show", "PostsController#new", "PostsController#create"]
          end

          it "should not add resources routes with only: :none" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resources :posts, only: :none
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 0
          end

          it "should not add resources routes with except: :all" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resources :posts, except: :all
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 0
          end

          it "should add resource routes with hash collection/member routes" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resources :posts, only: [:show], collection: { list: :get }, member: { create: :post, update: :put, destroy: :delete }
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 5
            routes.map(&:to_s).should == ["PostsController#show", "PostsController#create", "PostsController#update", "PostsController#destroy", "PostsController#list"]
          end

          it "should add resource routes with array collection/member routes" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resources :posts, only: [:show], collection: [:list], member: [:create, :update, :destroy]
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 5
            routes.map(&:to_s).should == ["PostsController#show", "PostsController#create", "PostsController#update", "PostsController#destroy", "PostsController#list"]
          end

          it "should add route with nested routes" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resources :posts do |post|
                post.resources :comments
              end
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 14
          end

          it "should add route with namespace" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.namespace :admin do |admin|
                admin.namespace :test do |test|
                  test.resources :posts, only: [:index]
                end
              end
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.map(&:to_s).should == ["Admin::Test::PostsController#index"]
          end
        end

        context "resource" do
          it "should add resource route" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resource :posts
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 6
            routes.map(&:to_s).should == ["PostsController#show", "PostsController#new", "PostsController#create", "PostsController#edit", "PostsController#update", "PostsController#destroy"]
          end

          it "should add multiple resource route" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resource :posts, :users
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 12
          end

          it "should add resource route with only option" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resource :posts, only: [:show, :new, :create]
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 3
            routes.map(&:to_s).should == ["PostsController#show", "PostsController#new", "PostsController#create"]
          end

          it "should add resource route with except option" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resource :posts, except: [:edit, :update, :destroy]
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 3
            routes.map(&:to_s).should == ["PostsController#show", "PostsController#new", "PostsController#create"]
          end

          it "should not add resource routes with only: :none" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resource :posts, only: :none
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 0
          end

          it "should not add resource routes with except: :all" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.resource :posts, except: :all
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 0
          end
        end

        it "should add connect route" do
          content =<<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.connect 'vote', controller: "votes", action: "create", method: :post
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.map(&:to_s).should == ["VotesController#create"]
        end

        it "should add connect route with all actions" do
          content =<<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.connect 'internal/:action/*whatever', controller: "internal"
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.map(&:to_s).should == ["InternalController#*"]
        end

        it "should add named route" do
          content =<<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.login '/player/login', controller: 'sessions', action: 'new', conditions: { method: :get }
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.map(&:to_s).should == ["SessionsController#new"]
        end

        it "should add named route with with_options" do
          content =<<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.with_options(controller: "admin_session") do |session|
              session.login '/login', action: 'new', method: :get
            end
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.map(&:to_s).should == ["AdminSessionController#new"]
        end

        it "should not take former resources for direct get/post" do
          content =<<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.resources :posts
            map.stop 'sprints/stop', controller: 'sprints', action: 'stop'
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.last.to_s.should == "SprintsController#stop"
        end
      end

      context "rails3" do
        context "resources" do
          it "should add resources route" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resources :posts
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 7
            routes.map(&:to_s).should == ["PostsController#index", "PostsController#show", "PostsController#new", "PostsController#create", "PostsController#edit", "PostsController#update", "PostsController#destroy"]
          end

          it "should add multiple resources route" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resources :posts, :users
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 14
          end

          it "should add resources route with explict controller" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resources :posts, controller: :blog_posts
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 7
            routes.map(&:to_s).should == ["BlogPostsController#index", "BlogPostsController#show", "BlogPostsController#new", "BlogPostsController#create", "BlogPostsController#edit", "BlogPostsController#update", "BlogPostsController#destroy"]
          end

          it "should add resources route with only option" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resources :posts, only: [:index, :show, :new, :create]
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 4
            routes.map(&:to_s).should == ["PostsController#index", "PostsController#show", "PostsController#new", "PostsController#create"]
          end

          it "should add resources route with except option" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resources :posts, except: [:edit, :update, :destroy]
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 4
            routes.map(&:to_s).should == ["PostsController#index", "PostsController#show", "PostsController#new", "PostsController#create"]
          end

          it "should not add resources routes with only: :none" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resources :posts, only: :none
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 0
          end

          it "should not add resources routes with except: :all" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resources :posts, except: :all
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 0
          end

          it "should add resources routes with members" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              namespace :admin do
                resources :posts, :only => [:edit, :update] do
                  member do
                    post 'link_to/:other_id' => 'posts#link_to_post'
                    post 'extra_update' => 'posts#extra_update'
                  end
                end
              end
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.map(&:to_s).should == [
              "Admin::PostsController#edit",
              "Admin::PostsController#update",
              "Admin::PostsController#link_to_post",
              "Admin::PostsController#extra_update"]
          end

          it "should add connect route" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.connect 'vote', controller: "votes", action: "create", method: :post
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.map(&:to_s).should == ["VotesController#create"]
          end

          it "should add named route" do
            content =<<-EOF
            ActionController::Routing::Routes.draw do |map|
              map.login '/player/login', controller: 'sessions', action: 'new', conditions: { method: :get }
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.map(&:to_s).should == ["SessionsController#new"]
          end
        end

        context "resource" do
          it "should add resource route" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resource :posts
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 6
            routes.map(&:to_s).should == ["PostsController#show", "PostsController#new", "PostsController#create", "PostsController#edit", "PostsController#update", "PostsController#destroy"]
          end

          it "should add multiple resource route" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resource :posts, :users
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 12
          end

          it "should add resource route with only option" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resource :posts, only: [:show, :new, :create]
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 3
            routes.map(&:to_s).should == ["PostsController#show", "PostsController#new", "PostsController#create"]
          end

          it "should add resource route with except option" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resource :posts, except: [:edit, :update, :destroy]
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 3
            routes.map(&:to_s).should == ["PostsController#show", "PostsController#new", "PostsController#create"]
          end

          it "should not add resource routes with only: :none" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resource :posts, only: :none
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 0
          end

          it "should not add resource routes with except: :all" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resource :posts, except: :all
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 0
          end

          it "should add resource routes with get/post/put/delete routes" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resources :posts, only: [:show] do
                get :list, on: :collection
                collection do
                  get :search
                  match :available
                end
                post :create, on: :member
                member do
                  put :update
                end
              end
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 6
            routes.map(&:to_s).should == ["PostsController#show", "PostsController#list", "PostsController#search", "PostsController#available", "PostsController#create", "PostsController#update"]
          end

          it "should add custom resources routes with {}" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resources :posts, only: [:show] { get :inactive, on: :collection }
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 2
            routes.map(&:to_s).should == ["PostsController#show", "PostsController#inactive"]
          end

          it "should add resources routes with get %w() routes" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resources :posts, only: [:show] do
                collection do
                  get *%w(latest popular)
                end
              end
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 3
            routes.map(&:to_s).should == ["PostsController#show", "PostsController#latest", "PostsController#popular"]
          end

          it "should add route with nested routes" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              resources :posts
                resources :comments
              end
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.size.should == 14
          end

          it "should add route with namespace" do
            content =<<-EOF
            RailsBestPracticesCom::Application.routes.draw do
              namespace :admin do
                namespace :test do
                  resources :posts, only: [:index]
                end
              end
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.map(&:to_s).should == ["Admin::Test::PostsController#index"]
          end

          it "should add route with namespace, but without resources" do
            content =<<-EOF
            RailsBestPracticesCom::Appllication.routes.draw do
              namespace :something do
                get *%w(route_one route_two)
                get :route_three, action: "custom_action"
              end
            end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.map(&:to_s).should == ["SomethingController#route_one", "SomethingController#route_two", "SomethingController#custom_action"]
          end

          it "should add route with scope" do
            content =<<-EOF
              RailsBestPracticesCom::Application.routes.draw do
                scope module: "admin" do
                  resources :posts, only: [:index]
                end
                resources :discussions, only: [:index], module: "admin"
                scope "/admin" do
                  resources :comments, only: [:index]
                end
                scope "/:username", controller: :users do
                  get '/' => :show
                  scope 'topic' do
                    get 'preview', as: 'preview_user', action: 'preview'
                  end
                end
              end
            EOF
            runner.prepare('config/routes.rb', content)
            routes = Prepares.routes
            routes.map(&:to_s).should == [
                                           "Admin::PostsController#index",
                                           "Admin::DiscussionsController#index",
                                           "CommentsController#index",
                                           "UsersController#show",
                                           "UsersController#preview"
                                         ]
          end
        end

        it "should add route for direct get/post" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            get 'posts/show'
            post '/posts' => 'posts#create'
            put '/posts/:id' => 'posts#update'
            delete '/post/:id' => 'posts#destroy'
            get '/agb' => 'high_voltage/pages#show', id: 'agb'
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.size.should == 5
          routes.map(&:to_s).should == ["PostsController#show", "PostsController#create", "PostsController#update", "PostsController#destroy", "HighVoltage::PagesController#show"]
        end

        it "should add routes for another get/post" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw
            get "/login", to: 'sessions#new', as: :login
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.size.should == 1
          routes.first.to_s.should == "SessionsController#new"
        end

        it "should add match route" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            match '/auth/:provider/callback' => 'authentications#create'
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.map(&:to_s).should == ["AuthenticationsController#create"]
        end

        it "should add match route with all actions" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            match 'internal/:action/*whatever', controller: "internal"
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.map(&:to_s).should == ["InternalController#*"]
        end

        it "should add root route" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            root to: 'home#index'
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.map(&:to_s).should == ["HomeController#index"]
        end

        it "should do nothing for default route" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            match ':controller(/:action(/:id(.:format)))'
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.size.should == 0
        end

        it "should do nothing for redirect" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            match "/stories/:name" => redirect("/posts/%{name}")
            match "/stories" => redirect {|p, req| "/posts/\#{req.subdomain}" }
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.size.should == 0
        end

        it "should parse customize route in nested resources" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts do
              resources :comments
              post :stop
            end
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.last.to_s.should == "PostsController#stop"
        end

        it "should not take former resources for direct get/post" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts
            post "sprints/stop"
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.last.to_s.should == "SprintsController#stop"
        end

        it "should not parse wrong route" do
          content =<<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            match ':controller/:action' => '#index', as: :auto_complete
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          routes.size.should == 0
        end
      end
    end
  end
end
