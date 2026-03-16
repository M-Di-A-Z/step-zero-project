class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business_idea

  def create
    @like = @business_idea.likes.find_or_create_by(user: current_user)
    render json: { liked: true, count: @business_idea.likes.count }
  end

  def destroy
    @like = @business_idea.likes.find_by(user: current_user)
    @like&.destroy
    render json: { liked: false, count: @business_idea.likes.count }
  end

  private

  def set_business_idea
    @business_idea = BusinessIdea.find(params[:business_idea_id])
  end
end
