Rails.application.routes.draw do

  root 'workers#index'

  resources :workers, only: [:index, :create, :edit, :update]
  resources :shifts, only: [:index, :create, :edit, :update]

end
