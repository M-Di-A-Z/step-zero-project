class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def after_sign_in_path_for(resource)
    if session[:pending_idea_content].present?
      idea = resource.business_ideas.create!(
        content: session.delete(:pending_idea_content),
        status: "pending"
      )
      chat = Chat.create!(business_idea: idea)
      chat_path(chat)
    else
      root_path
    end
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end
end
