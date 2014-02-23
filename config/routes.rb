Dataflow::Application.routes.draw do  
  resources :databases, only: [:new, :create] do #, :edit, :update, :destroy]
    resources :dynamic_columns, only: [:new, :create]
  end
  resources :query, only: [:index, :show]
  root to: "query#index"
end
