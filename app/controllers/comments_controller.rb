class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business_idea

  def index
    @comments = @business_idea.comments.includes(:user).order(created_at: :desc)
    render partial: "comments/list", locals: { comments: @comments, business_idea: @business_idea }
  end

  def create
    @comment = @business_idea.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      @comments = @business_idea.comments.includes(:user).order(created_at: :desc)
      render partial: "comments/list", locals: { comments: @comments, business_idea: @business_idea }
    else
      head :unprocessable_entity
    end
  end

  def destroy
    @comment = @business_idea.comments.find(params[:id])
    if @comment.user == current_user
      @comment.destroy
      @comments = @business_idea.comments.includes(:user).order(created_at: :desc)
      render partial: "comments/list", locals: { comments: @comments, business_idea: @business_idea }
    else
      head :forbidden
    end
  end

  private

  def set_business_idea
    @business_idea = BusinessIdea.find(params[:business_idea_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
