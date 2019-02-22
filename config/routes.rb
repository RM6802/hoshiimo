Rails.application.routes.draw do
  devise_for :users,
    path: "",
    path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' },
    controllers: { registrations: 'registrations' }

  root to: "home#index"
  get  '/about',   to: 'home#about'

  resources :users, only: [:index, :show] do
    #get "search", on: :collection
    resources :posts, only: [:index]
  end

  resources :posts
end
