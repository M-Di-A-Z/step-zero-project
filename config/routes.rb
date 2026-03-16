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
<<<<<<< HEAD
        get :preview
=======
>>>>>>> 5db03a2d50b91dc2a26231e445c070ed9cdfc0ff
        patch :share
    end
  end

  resources :chats, only: [:show ] do
    resources :messages, only: [:create]
  end

  resource :profile, only: [:show, :edit, :update]

<<<<<<< HEAD
  get "socials", to: "socials#index", as: :socials
  get "socials/share", to: "socials#share", as: :share_socials
=======
  get "socials/share", to: "socials#share", as: :share_socials
  get "socials", to: "socials#index", as: :socials
>>>>>>> 5db03a2d50b91dc2a26231e445c070ed9cdfc0ff

  get "up" => "rails/health#show", as: :rails_health_check
  get "report", to: "business_ideas#report"


end
