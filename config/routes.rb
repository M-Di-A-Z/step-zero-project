Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  resources :business_ideas, only: [:new, :create, :index, :show, :destroy] do
    resources :business_datas, only: [:create]
    member do
        get :report
        get :status
        get :research
        post :research
        get :preview
        patch :share
    end
  end

  resources :chats, only: [:show ] do
    resources :messages, only: [:create]
  end

  resource :profile, only: [:show, :edit, :update]

  get "socials", to: "socials#index", as: :socials
  get "socials/share", to: "socials#share", as: :share_socials

  get "up" => "rails/health#show", as: :rails_health_check
  get "report", to: "business_ideas#report"


end
