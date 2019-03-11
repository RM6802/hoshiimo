Rails.application.routes.draw do
  devise_for :users,
    path: "",
    path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' },
    controllers: { registrations: 'registrations' }

  root to: 'home#index'
  get  'about',   to: 'home#about'
  get 'bad_request' => 'home#bad_request'
  get 'forbidden' => 'home#forbidden'
  get 'internal_server_error' => 'home#internal_server_error'

  resources :users, only: [:index, :show] do
    resources :posts, only: [:index]
    resources :purchases, only: [:index]
    resources :unpurchases, only: [:index]
  end

  resources :posts
  resources :purchases, only: [:index]
  resources :unpurchases, only: [:index]
end
