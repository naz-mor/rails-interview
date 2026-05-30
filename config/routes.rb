Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index create], path: :todolists
  end

  resources :todo_lists, only: %i[index new create edit update destroy], path: :todolists
end
