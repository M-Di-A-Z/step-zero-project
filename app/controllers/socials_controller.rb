class SocialsController < ApplicationController
  def index
    trending_ids = Like
      .joins(:business_idea)
      .where(business_ideas: { shared: true })
      .group(:business_idea_id)
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(2)
      .pluck(:business_idea_id)

    @trending_posts = trending_ids.any? ? BusinessIdea.where(id: trending_ids).includes(:user, :likes, comments: :user) : []

    @posts = BusinessIdea.where(shared: true)
                         .where.not(id: trending_ids)
                         .includes(:user, :likes, comments: :user)
                         .order(created_at: :desc)
  end
end
