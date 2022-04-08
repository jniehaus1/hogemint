Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :test_items, only: [:new, :create, :show, :index]
  resources :items, only: :show

  get 'faq',   to:'statics#faq'
  get 'guide', to:'statics#guide'

  if ENV["PRINTER_IS_LIVE"] == 'true'
    root to: 'items#new'
    resources :items, only: [:new, :create] do
      collection do
        get 'uri'
      end
    end
  else
    root to: 'test_items#new'
  end
end
