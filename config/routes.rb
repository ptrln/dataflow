Dataflow::Application.routes.draw do
  
  resources :databases

  root :to => 'databases#index'
end
