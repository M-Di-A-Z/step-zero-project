class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @business_idea = @chat.business_idea
    @message = @chat.messages.build(message_params.merge(role: "user"))

    if @message.save
      response = ClaudeService.new(@chat).ask
      @assistant_message = @chat.messages.create!(role: "assistant", content: response)
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
