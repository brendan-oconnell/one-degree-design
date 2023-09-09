Rails.application.routes.draw do
  # users are currently hidden in view, but functionality is built out.
  devise_for :users, components: {registrations: 'registrations', sessions: 'sessions'}

  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    # use Sidekiq for background jobs (website carbon API, image scraping, font and background color scraping)
    # so results page doesn't take too long to load.
    mount Sidekiq::Web => '/sidekiq'
  end

  # pages
  root to: 'pages#home'

  # website

  resources :websites, only: :create

  #version

  resources :versions, only: :show

  # dashboard
  # not currently available in view
  get 'dashboard', to: 'pages#dashboard', as: :dashboard

  # footer
  get 'about', to: 'pages#about'
  get 'scrapingerror', to: 'pages#scrapingerror'
  get 'howitworks', to: 'pages#howitworks', as: :howitworks
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

end
