class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @business_idea = @chat.business_idea
    @message = @chat.messages.build(message_params.merge(role: "user"))

    if @message.save
      response = ClaudeService.new(@chat).ask

      if response.include?("[RESEARCH_READY]")
        @assistant_message = @chat.messages.create!(
          role: "assistant",
          content: "Got it! I have everything I need. Starting research now..."
        )
        @business_idea.update!(status: "researching")
        ResearchBusinessIdeaJob.perform_later(@business_idea.id)
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
