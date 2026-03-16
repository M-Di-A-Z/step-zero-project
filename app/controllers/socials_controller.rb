class SocialsController < ApplicationController
  def index
    @posts = BusinessIdea.where(shared: true)
                         .includes(:user, :likes, :comments)
                         .order(created_at: :desc)
  end

  def share
    @my_ideas = current_user.business_ideas.where.not(status: ["pending", "in progress"])
                             .includes(:likes, :comments)
                             .order(created_at: :desc)
  end
end
