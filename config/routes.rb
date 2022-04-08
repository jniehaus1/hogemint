require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :test_items, only: [:new, :create, :show]
  resources :items,      only: [:show]
  resources :base_items, only: [:new, :create, :show] do
    member do
      post :skip_payment
    end
  end

  # item URLs
  get '/uri/:id', to: 'items#uri', as: "item_uri"

  get 'sales/checkout/:id', to: 'sales#checkout', as: 'sales_checkout'
  get 'sales/base_checkout/:id', to: 'sales#base_checkout', as: 'sales_base_checkout'
  post 'sales/reset_gas', to: 'sales#reset_gas', as: 'reset_gas'

  # base_item URLs
  get  '/new_session', to: 'base_items#new_session'
  post '/login',       to: 'base_items#login'

  # Static URLs
  get 'faq',      to: 'statics#faq'
  get 'guide',    to: 'statics#guide'
  get 'support',  to: 'statics#support'

  post 'callback/coingate', to: 'callbacks#coingate'
  post 'callback/nowpayments', to: 'callbacks#now_payments'

  devise_for :users, controllers: { sessions: 'admin/sessions', passwords: 'admin/passwords' }, skip: [:registrations]

  namespace :admin do
    get 'dashboard', to: 'dashboards#dashboard'
  end

  if ENV["PRINTER_IS_LIVE"] == 'true'
    root to: 'items#new'
    get 'items', to: 'items#new'
    resources :items, only: [:new, :create]
  else
    root to: 'test_items#new'
  end

  mount Sidekiq::Web => '/sidekiq'
end
