Dataflow::Application.routes.draw do  
  resources :databases, only: [:new, :create]#, :edit, :update, :destroy]
  resources :query, only: [:index, :show]
  root to: "query#index"
end
