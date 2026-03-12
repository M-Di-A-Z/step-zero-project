class ClaudeService
  CHAT_SYSTEM_PROMPT = <<~PROMPT
    You are an expert business analyst helping a founder validate their business idea.
    Your role is to ask 3 concise clarifying questions — one at a time — to understand:
    1. The core features they plan to build
    2. Their target market (who they are building for)
    After the founder has answered, summarize what you've learned and confirm
    their details in a brief closing message.
    Keep your tone friendly, direct, and professional. Do not repeat questions already asked.
  PROMPT

  def initialize(chat)
    @chat = chat
    @business_idea = chat.business_idea
  end

  def ask
    llm_chat = RubyLLM.chat(
      model: "claude-sonnet-4-20250514",
      system: "#{CHAT_SYSTEM_PROMPT}\n\nThe business idea: #{@business_idea.content}"
    )

    # Replay full message history without triggering API calls
    @chat.messages.order(:created_at).each do |m|
      llm_chat.add_message(role: m.role.to_sym, content: m.content)
    end

    # Trigger a single API call with the full history
    response = llm_chat.complete
    response.content || "Sorry, I couldn't generate a response."
  rescue => e
    Rails.logger.error("ClaudeService#ask error: #{e.message}")
    "Sorry, I encountered an error. Please try again."
  end
end
