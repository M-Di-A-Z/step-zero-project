class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @business_ideas = @user.business_ideas.order(created_at: :desc)
    @total_projects = @business_ideas.count
    @completed_projects = @business_ideas.where(status: "complete").count
    @average_score = @business_ideas.where.not(idea_score: nil).average(:idea_score)&.round || 0
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :email, :avatar)
  end
end
