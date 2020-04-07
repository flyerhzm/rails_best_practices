# frozen_string_literal: true

require 'spec_helper'

module RailsBestPractices
  module Prepares
    describe RoutePrepare do
      let(:runner) { Core::Runner.new(prepares: described_class.new) }

      context 'resources' do
        it 'adds resources route' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(7)
          expect(routes.map(&:to_s)).to eq(
            [
              'PostsController#index',
              'PostsController#show',
              'PostsController#new',
              'PostsController#create',
              'PostsController#edit',
              'PostsController#update',
              'PostsController#destroy'
            ]
          )
        end

        it 'adds multiple resources route' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts, :users
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(14)
        end

        it 'adds resources route with explict controller' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts, controller: :blog_posts
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(7)
          expect(routes.map(&:to_s)).to eq(
            [
              'BlogPostsController#index',
              'BlogPostsController#show',
              'BlogPostsController#new',
              'BlogPostsController#create',
              'BlogPostsController#edit',
              'BlogPostsController#update',
              'BlogPostsController#destroy'
            ]
          )
        end

        it 'adds resources route with only option' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts, only: [:index, :show, :new, :create]
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(4)
          expect(routes.map(&:to_s)).to eq(
            ['PostsController#index', 'PostsController#show', 'PostsController#new', 'PostsController#create']
          )
        end

        it 'adds resources route with except option' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts, except: [:edit, :update, :destroy]
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(4)
          expect(routes.map(&:to_s)).to eq(
            ['PostsController#index', 'PostsController#show', 'PostsController#new', 'PostsController#create']
          )
        end

        it 'does not add resources routes with only: :none' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts, only: :none
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(0)
        end

        it 'does not add resources routes with except: :all' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts, except: :all
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(0)
        end

        it 'adds resources routes with members' do
          content = <<-EOF
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
          expect(routes.map(&:to_s)).to eq(
            [
              'Admin::PostsController#edit',
              'Admin::PostsController#update',
              'Admin::PostsController#link_to_post',
              'Admin::PostsController#extra_update'
            ]
          )
        end

        it 'adds resources routes with members inline' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            namespace :admin do
              resources :posts, :only => [:edit, :update] do
                post :link_to_post, :extra_update, :retrieve, on: :member
              end
            end
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.map(&:to_s)).to eq(
            [
              'Admin::PostsController#edit',
              'Admin::PostsController#update',
              'Admin::PostsController#link_to_post',
              'Admin::PostsController#extra_update',
              'Admin::PostsController#retrieve'
            ]
          )
        end

        it 'adds connect route' do
          content = <<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.connect 'vote', controller: "votes", action: "create", method: :post
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.map(&:to_s)).to eq(['VotesController#create'])
        end

        it 'adds named route' do
          content = <<-EOF
          ActionController::Routing::Routes.draw do |map|
            map.login '/player/login', controller: 'sessions', action: 'new', conditions: { method: :get }
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.map(&:to_s)).to eq(['SessionsController#new'])
        end
      end

      context 'resource' do
        it 'adds resource route' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resource :posts
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(6)
          expect(routes.map(&:to_s)).to eq(
            [
              'PostsController#show',
              'PostsController#new',
              'PostsController#create',
              'PostsController#edit',
              'PostsController#update',
              'PostsController#destroy'
            ]
          )
        end

        it 'adds multiple resource route' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resource :posts, :users
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(12)
        end

        it 'adds resource route with only option' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resource :posts, only: [:show, :new, :create]
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(3)
          expect(routes.map(&:to_s)).to eq(['PostsController#show', 'PostsController#new', 'PostsController#create'])
        end

        it 'adds resource route with except option' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resource :posts, except: [:edit, :update, :destroy]
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(3)
          expect(routes.map(&:to_s)).to eq(['PostsController#show', 'PostsController#new', 'PostsController#create'])
        end

        it 'does not add resource routes with only: :none' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resource :posts, only: :none
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(0)
        end

        it 'does not add resource routes with except: :all' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resource :posts, except: :all
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(0)
        end

        it 'adds resource routes with get/post/put/patch/delete routes' do
          content = <<-EOF
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
                patch :update
              end
            end
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(7)
          expect(routes.map(&:to_s)).to eq(
            [
              'PostsController#show',
              'PostsController#list',
              'PostsController#search',
              'PostsController#available',
              'PostsController#create',
              'PostsController#update',
              'PostsController#update'
            ]
          )
        end

        it 'adds custom resources routes with {}' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts, only: [:show] do
              get :inactive, on: :collection
            end
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(2)
          expect(routes.map(&:to_s)).to eq(['PostsController#show', 'PostsController#inactive'])
        end

        it 'adds resources routes with get %w() routes' do
          content = <<-EOF
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
          expect(routes.size).to eq(3)
          expect(routes.map(&:to_s)).to eq(
            ['PostsController#show', 'PostsController#latest', 'PostsController#popular']
          )
        end

        it 'adds route with nested routes' do
          content = <<-EOF
          RailsBestPracticesCom::Application.routes.draw do
            resources :posts
              resources :comments
            end
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.size).to eq(14)
        end

        it 'adds route with namespace' do
          content = <<-EOF
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
          expect(routes.map(&:to_s)).to eq(['Admin::Test::PostsController#index'])
        end

        it 'adds route with namespace, but without resources' do
          content = <<-EOF
          RailsBestPracticesCom::Appllication.routes.draw do
            namespace :something do
              get *%w(route_one route_two)
              get :route_three, action: "custom_action"
            end
          end
          EOF
          runner.prepare('config/routes.rb', content)
          routes = Prepares.routes
          expect(routes.map(&:to_s)).to eq(
            ['SomethingController#route_one', 'SomethingController#route_two', 'SomethingController#custom_action']
          )
        end

        it 'adds route with scope' do
          content = <<-EOF
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
          expect(routes.map(&:to_s)).to eq(
            [
              'Admin::PostsController#index',
              'Admin::DiscussionsController#index',
              'CommentsController#index',
              'UsersController#show',
              'UsersController#preview'
            ]
          )
        end
      end

      it 'adds route for direct get/post' do
        content = <<-EOF
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
        expect(routes.size).to eq(5)
        expect(routes.map(&:to_s)).to eq(
          [
            'PostsController#show',
            'PostsController#create',
            'PostsController#update',
            'PostsController#destroy',
            'HighVoltage::PagesController#show'
          ]
        )
      end

      it 'adds routes for another get/post' do
        content = <<-EOF
        RailsBestPracticesCom::Application.routes.draw
          get "/login", to: 'sessions#new', as: :login
        end
        EOF
        runner.prepare('config/routes.rb', content)
        routes = Prepares.routes
        expect(routes.size).to eq(1)
        expect(routes.first.to_s).to eq('SessionsController#new')
      end

      it 'adds match route' do
        content = <<-EOF
        RailsBestPracticesCom::Application.routes.draw do
          match '/auth/:provider/callback' => 'authentications#create'
        end
        EOF
        runner.prepare('config/routes.rb', content)
        routes = Prepares.routes
        expect(routes.map(&:to_s)).to eq(['AuthenticationsController#create'])
      end

      it 'adds match route with all actions' do
        content = <<-EOF
        RailsBestPracticesCom::Application.routes.draw do
          match 'internal/:action/*whatever', controller: "internal"
        end
        EOF
        runner.prepare('config/routes.rb', content)
        routes = Prepares.routes
        expect(routes.map(&:to_s)).to eq(['InternalController#*'])
      end

      it 'adds root route' do
        content = <<-EOF
        RailsBestPracticesCom::Application.routes.draw do
          root to: 'home#index'
        end
        EOF
        runner.prepare('config/routes.rb', content)
        routes = Prepares.routes
        expect(routes.map(&:to_s)).to eq(['HomeController#index'])
      end

      it 'adds root shortcut route' do
        content = <<-EOF
        RailsBestPracticesCom::Application.routes.draw do
          root 'home#index'
        end
        EOF
        runner.prepare('config/routes.rb', content)
        routes = Prepares.routes
        expect(routes.map(&:to_s)).to eq(['HomeController#index'])
      end

      it 'does nothing for default route' do
        content = <<-EOF
        RailsBestPracticesCom::Application.routes.draw do
          match ':controller(/:action(/:id(.:format)))'
        end
        EOF
        runner.prepare('config/routes.rb', content)
        routes = Prepares.routes
        expect(routes.size).to eq(0)
      end

      it 'does nothing for redirect' do
        content = <<-EOF
        RailsBestPracticesCom::Application.routes.draw do
          match "/stories/:name" => redirect("/posts/%{name}")
          match "/stories" => redirect {|p, req| "/posts/\#{req.subdomain}" }
        end
        EOF
        runner.prepare('config/routes.rb', content)
        routes = Prepares.routes
        expect(routes.size).to eq(0)
      end

      it 'parses customize route in nested resources' do
        content = <<-EOF
        RailsBestPracticesCom::Application.routes.draw do
          resources :posts do
            resources :comments
            post :stop
          end
        end
        EOF
        runner.prepare('config/routes.rb', content)
        routes = Prepares.routes
        expect(routes.last.to_s).to eq('PostsController#stop')
      end

      it 'parses custom route for resource with explicit to and different action name' do
        content = <<-EOF
        RailsBestPracticesCom::Application.routes.draw do
          resources :posts do
            get :halt, to: 'posts#stop'
          end
        end
        EOF
        runner.prepare('config/routes.rb', content)
        routes = Prepares.routes
        expect(routes.last.to_s).to eq('PostsController#stop')
      end

      it 'parses custom route for resource with symbol action name' do
        content = <<-EOF
        RailsBestPracticesCom::Application.routes.draw do
          resources :posts do
            get :halt, to: :stop
          end
        end
        EOF
        runner.prepare('config/routes.rb', content)
        routes = Prepares.routes
        expect(routes.last.to_s).to eq('PostsController#stop')
      end

      it 'does not take former resources for direct get/post' do
        content = <<-EOF
        RailsBestPracticesCom::Application.routes.draw do
          resources :posts
          post "sprints/stop"
        end
        EOF
        runner.prepare('config/routes.rb', content)
        routes = Prepares.routes
        expect(routes.last.to_s).to eq('SprintsController#stop')
      end

      it 'does not parse wrong route' do
        content = <<-EOF
        RailsBestPracticesCom::Application.routes.draw do
          match ':controller/:action' => '#index', as: :auto_complete
        end
        EOF
        runner.prepare('config/routes.rb', content)
        routes = Prepares.routes
        expect(routes.size).to eq(0)
      end
    end
  end
end
