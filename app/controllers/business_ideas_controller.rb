class BusinessIdeasController < ApplicationController
  def new
    @business_idea = BusinessIdea.new
  end

  def create
    @business_idea = BusinessIdea.new(business_idea_params)
    @business_idea.user = current_user
    @business_idea.status = "pending"
    if @business_idea.save
      chat = Chat.create!(business_idea: @business_idea)
      redirect_to chat_path(chat)
    else
      render :new, status: :unprocessable_entity
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

  private

  def business_idea_params
    params.require(:business_idea).permit(:content)
  end
end
