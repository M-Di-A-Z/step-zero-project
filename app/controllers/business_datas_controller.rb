class BusinessDatasController < ApplicationController
  def create
    @business_idea = current_user.business_ideas.find(params[:business_idea_id])
    @business_idea.update!(status: "researching")
    ResearchBusinessIdeaJob.perform_later(@business_idea.id)
    redirect_to business_idea_path(@business_idea)
  end
end
