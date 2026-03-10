class ChatsController < ApplicationController
  def show
    @chat = Chat.find(params[:id])
    @business_idea = @chat.business_idea
    @message = Message.new
  end
end
