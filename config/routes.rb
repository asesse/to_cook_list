Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users, only: %i[show create update destroy]
  resources :stocks, only: %i[show] do 
    resources :ingredients, only: %i[create update destroy], controller: 'stocks/ingredients', param: :ingredient_id
  end
  resources :ingredients, only: :index
end
