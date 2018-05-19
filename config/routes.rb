Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :games, only: [:create, :update], format: :json do
    resources :charter_flights, only: :create, format: :json
    resources :direct_flights, only: :create, format: :json
    resources :get_cards, only: :create, format: :json
    resources :give_cards, only: :create, format: :json
    resources :invitations, only: [:create, :update, :destroy], format: :json
    resources :line_movements, only: :create, format: :json
    resources :research_stations, only: :create, format: :json
    resources :share_cards, only: :update, format: :json
    resources :shuttle_flights, only: :create, format: :json
  end
  post 'authenticate', to: 'authentication#authenticate'
end
