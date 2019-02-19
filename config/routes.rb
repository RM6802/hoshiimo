Rails.application.routes.draw do
  devise_for :users, controllers: {
        registrations: 'registrations'
      }
  root to: "home#index"
  get  '/about',   to: 'home#about'

  resources :users, only: [:index, :show]
end
