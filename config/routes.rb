Rails.application.routes.draw do
  # get 'users/new'
  get 'users/new', to:'users#new'
  resources :users
end
