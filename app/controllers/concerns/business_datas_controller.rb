class BusinessDatasController < ApplicationController
  before_action :authenticate_user!

  def create
    @business_idea = BusinessIdea.find(params[:business_idea_id])
    @business_idea.update!(status: "researching")
  end
end
