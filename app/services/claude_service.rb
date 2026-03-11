class ClaudeService
  SYSTEM_PROMPT = <<~PROMPT
    You are an expert business analyst helping a founder validate their business idea.
    Your role is to ask 3 concise clarifying questions — one at a time — to understand:
    1. The core features they plan to build
    2. Their target market (who they are building for)

    After the founder has answered your questions, summarize what you've learned and confirm
    their details (features and target market) in a brief closing message.

    Keep your tone friendly, direct, and professional. Do not repeat questions already asked.
  PROMPT

  def initialize(chat)
    @chat = chat
    @business_idea = chat.business_idea
  end

  def ask
    client = Anthropic::Client.new(api_key: ENV["ANTHROPIC_API_KEY"])

    messages = @chat.messages.order(:created_at).map do |m|
      { role: m.role, content: m.content }
    end

    response = client.messages(
      model: "claude-sonnet-4-20250514",
      max_tokens: 1024,
      system: "#{SYSTEM_PROMPT}\n\nThe business idea: #{@business_idea.content}",
      messages: messages
    )

    response.content.first.text
  rescue Anthropic::Error => e
    Rails.logger.error("ClaudeService error: #{e.message}")
    "Sorry, I encountered an error. Please try again."
  end
end
