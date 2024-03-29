Rails.application.routes.draw do
  # post 'users/create'
  # put 'users/update/:id'
  resources :users, only: [:create, :update]

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
