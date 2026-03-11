class ChatsController < ApplicationController
  def show
    @chat = Chat.find(params[:id])
    @business_idea = @chat.business_idea
    @message = Message.new

    if @chat.messages.empty?
      first_response = ClaudeService.new(@chat).ask
      @chat.messages.create!(role: "assistant", content: first_response)
    end
  end
end
