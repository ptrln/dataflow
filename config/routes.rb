Dataflow::Application.routes.draw do  
  resources :databases

  root to: "query#index"
end
