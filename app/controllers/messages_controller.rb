class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @business_idea = @chat.business_idea
    @message = @chat.messages.build(message_params.merge(role: "user"))

    if @message.save
      response = ClaudeService.new(@chat).ask

      @research_ready = response.include?("[RESEARCH_READY]")

      if @research_ready
        @assistant_message = @chat.messages.create!(
          role: "assistant",
          content: "I've got all the info I need now, let's generate the research."
        )
      else
        @assistant_message = @chat.messages.create!(role: "assistant", content: response)
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_path(@chat) }
      end
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
