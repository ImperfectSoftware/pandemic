Rails.application.routes.draw do
  scope '/', defaults: { format: :json } do
    post 'authenticate', to: 'authentication#authenticate'
    resources :games, only: [:create, :update, :index, :show] do
      resources :cure_diseases, only: :create
      resources :charter_flights, only: :create
      resources :direct_flights, only: :create
      resources :get_cards, only: :create
      resources :give_cards, only: :create
      resources :line_movements, only: :create
      resources :movement_proposals, only: [:create, :update]
      resources :operations_expert_flights, only: :create
      resources :research_stations, only: :create
      delete "/research_stations/:city_staticid", to: "research_stations#destroy"
      resources :share_cards, only: :update
      resources :shuttle_flights, only: :create
      resources :treat_diseases, only: :create

      scope module: :games, path: '' do
        resource :invitations, only: [:create, :update, :destroy]
        resource :infections, only: :create
        resource :discard_cards, only: :destroy
        resource :flip_cards, only: :create
        resource :forecasts, only: [:create, :update]
        resource :government_grant, only: :create
        resource :possible_actions, only: :show
        resource :possible_player_actions, only: :show
        resource :resilient_populations, only: [:show, :create]
        resource :skip_infections, only: :create
        resource :special_cards, only: :create
        resource :stage_two_epidemics, only: :create
      end
    end
    resources :invitations, only: :index
  end
end
