class BusinessIdeasController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]

  def new
    @business_idea = BusinessIdea.new
  end

  def create
    unless user_signed_in?
      session[:pending_idea_content] = params[:business_idea][:content]
      redirect_to new_user_registration_path, notice: "Create a free account — your idea will be saved!"
      return
    end

    @business_idea = BusinessIdea.new(business_idea_params)
    @business_idea.user = current_user
    @business_idea.status = 1
    if @business_idea.save
      chat = Chat.create!(business_idea: @business_idea)
    else
      render :new, status: :unprocessable_entity
      @business_idea.status = "pending"
    end
  end

  def index
    @business_ideas = current_user.business_ideas
  end

  def show
    @business_idea = current_user.business_ideas.find(params[:id])
  end

  def destroy
    @business_idea = current_user.business_ideas.find(params[:id])
    @business_idea.destroy
    redirect_to business_ideas_path
  end

  def report
    @business_idea = BusinessIdea.find(params[:id])
    @business_data = @business_idea.business_data
  end

  private

  def business_idea_params
    params.require(:business_idea).permit(:content)
  end
end
