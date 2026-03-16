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
      redirect_to chat_path(chat)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @business_ideas = current_user.business_ideas.where.not(status: ["pending", "in progress"])
  end

  def show
    @business_idea = current_user.business_ideas.find(params[:id])
  end

  def destroy
    @business_idea = current_user.business_ideas.find(params[:id])
    @business_idea.destroy
    redirect_to business_ideas_path
  end

  def research
    @business_idea = current_user.business_ideas.find(params[:id])
    @business_idea.update!(status: "researching")
    ResearchBusinessIdeaJob.perform_later(@business_idea.id)
    redirect_to business_idea_path(@business_idea)
  end

  def status
    @business_idea = current_user.business_ideas.find(params[:id])
    render json: { status: @business_idea.status }
  end

  def report
    @business_idea = BusinessIdea.find(params[:id])
    @business_data = @business_idea.business_data
  end

  def share
    @business_idea = current_user.business_ideas.find(params[:id])
    @business_idea.update(shared: !@business_idea.shared)
    redirect_to socials_path
  end

  private

  def business_idea_params
    params.require(:business_idea).permit(:content)
  end
end
