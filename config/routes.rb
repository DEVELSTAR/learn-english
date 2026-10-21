Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root "home#index"

  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token
  resource :registration, only: %i[new create]

  resources :lessons, only: %i[index show] do
    member do
      post :toggle_completion
      post :toggle_revision
      delete :clear_chat
    end
    resources :chat_messages, only: %i[create], module: :lessons
    resources :comments, only: %i[index create destroy], controller: "lesson_comments"
  end

  resources :topics, only: %i[index show] do
    resources :comments, only: %i[index create destroy], controller: "lesson_comments"
  end

  resources :notes, only: %i[index create edit update destroy]
  resources :note_shares, only: %i[create destroy] do
    member do
      post :accept
      post :decline
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
