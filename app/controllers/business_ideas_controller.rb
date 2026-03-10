class BusinessIdeasController < ApplicationController
  def new
    @business_idea = BusinessIdea.new
  end

  def create
    @business_idea = BusinessIdea.new(business_idea_params)
    @business_idea.chat = @chat
    @business_idea.save
    # redirect-to business_idea_path(@chat)
  end

  def index
    @business_idea = BusinessIdea.all
  end

  def show
    @business_idea = BusinessIdea.find(params[:id])
  end

  def destroy
    @business_idea = BusinessIdea.find(params[:id])
    @chat = @business_idea.chat
    if @business_idea.destroy
      redirect_to business_idea_path
    else
      render "business_idea/show"
    end
  end

  private
  def business_idea_params
    params.require(:user_id) permit(:title, :content, status:, report:)
  end

  end
end
