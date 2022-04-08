require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :test_items, only: [:new, :create, :show]
  resources :items,      only: [:show]
  resources :base_items, only: [:new, :create, :show]

  # item URLs
  get '/uri/:id', to: 'items#uri'
  get 'item/remint/:id', to: 'items#remint', as: "remint_item"

  # base_item URLs
  get  '/new_session', to: 'base_items#new_session'
  post '/login',       to: 'base_items#login'

  # Static URLs
  get 'faq',      to: 'statics#faq'
  get 'guide',    to: 'statics#guide'

  post 'coingate/callback', to: 'coingates#callback'

  if ENV["PRINTER_IS_LIVE"] == 'true'
    root to: 'items#new'
    resources :items, only: [:new, :create]
  else
    root to: 'test_items#new'
  end

  # if Rails.env == "development"
  mount Sidekiq::Web => "/sidekiq" # mount Sidekiq::Web in your Rails app
  # end
end
