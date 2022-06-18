Rails.application.routes.draw do
  devise_for :users

  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # pages
  root to: 'pages#home'

  # website

  resources :websites, only: :create

  #version

  resources :versions, only: :show

  # dashboard

  get 'dashboard', to: 'pages#dashboard', as: :dashboard

  # footer
  get 'about', to: 'pages#about'
  get 'howitworks', to: 'pages#howitworks', as: :howitworks
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

end
