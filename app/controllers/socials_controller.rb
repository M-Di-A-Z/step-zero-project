class SocialsController < ApplicationController
  def index
    trending_ids = Like
      .where(created_at: 24.hours.ago..)
      .joins(:business_idea)
      .where(business_ideas: { shared: true })
      .group(:business_idea_id)
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(2)
      .pluck(:business_idea_id)

    @trending_posts = trending_ids.any? ? BusinessIdea.where(id: trending_ids).includes(:user, :likes, comments: :user).to_a : []

    if @trending_posts.size < 2
      exclude_ids = trending_ids + @trending_posts.map(&:id)
      filler = BusinessIdea.where(shared: true)
                           .where.not(id: exclude_ids)
                           .includes(:user, :likes, comments: :user)
                           .order(created_at: :desc)
                           .limit(2 - @trending_posts.size)
      @trending_posts += filler.to_a
    end

    @posts = BusinessIdea.where(shared: true)
                         .where.not(id: @trending_posts.map(&:id))
                         .includes(:user, :likes, comments: :user)
                         .order(created_at: :desc)
  end
end
