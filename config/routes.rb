require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :test_items, only: [:new, :create, :show]
  resources :items,      only: [:show]
  resources :base_items, only: [:new, :create, :show]

  # item URLs
  get '/uri/:id', to: 'items#uri', as: "item_uri"

  get 'sales/checkout/:id', to: 'sales#checkout', as: 'sales_checkout'
  get 'sales/base_checkout/:id', to: 'sales#base_checkout', as: 'sales_base_checkout'

  # base_item URLs
  get  '/new_session', to: 'base_items#new_session'
  post '/login',       to: 'base_items#login'

  # Static URLs
  get 'faq',      to: 'statics#faq'
  get 'guide',    to: 'statics#guide'

  post 'callback/coingate', to: 'callbacks#coingate'
  post 'callback/nowpayments', to: 'callbacks#now_payments'

  if ENV["PRINTER_IS_LIVE"] == 'true'
    root to: 'items#new'
    resources :items, only: [:new, :create]
  else
    root to: 'test_items#new'
  end

  mount Sidekiq::Web => '/sidekiq'
end
