class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @business_idea = BusinessIdea.new
  end
end
