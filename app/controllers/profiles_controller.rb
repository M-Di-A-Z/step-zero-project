class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @business_ideas = @user.business_ideas.where(status: "complete").order(created_at: :desc)
    @total_projects = @user.business_ideas.count
    @completed_projects = @user.business_ideas.where(status: "complete").count
    @shared_projects = @user.business_ideas.where(shared: true).count
    @average_score = @user.business_ideas.where(status: "complete").where.not(idea_score: nil).average(:idea_score)&.round || 0
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
