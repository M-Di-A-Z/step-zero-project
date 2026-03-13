require "net/http"
require "json"

class ClaudeService
  ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages".freeze

  RESEARCH_SYSTEM_PROMPT = <<~PROMPT
    You are an expert market research analyst. You will receive a business idea and a conversation where the user clarified key details.

    Your job: use web search to research this idea thoroughly, then return a single JSON object with your findings.

    ## Research instructions
    - Search for real competitors, real market data, real revenue figures
    - Use multiple searches to cover: market size, competitors, business model viability, technical feasibility, regulatory landscape
    - Be specific with numbers — use real data when available, educated estimates when not
    - For competitors, find actual companies, not generic descriptions

    ## Output format
    Return ONLY this exact JSON structure. No markdown, no preamble, no ```json fences. Just raw JSON.

    {
      "project_name": "",
      "summary": "",
      "idea_score": 0,
      "overview": {
        "market_stage_pill": "",
        "market_stage_label": "",
        "market_stage_context": "",
        "competitive_intensity_dots": 0,
        "competitive_intensity_label": "",
        "competitive_intensity_context": "",
        "project_feasibility": "",
        "project_feasibility_context": "",
        "positioning_sentence": ""
      },
      "market": {
        "tam": "",
        "sam": "",
        "market_stage": "",
        "key_driver": "",
        "geo": [
          { "region": "", "pct": 0 }
        ]
      },
      "competitors": {
        "intensity": "",
        "intensity_dots": 0,
        "competitor_count": 0,
        "market_gap": "",
        "top_3": [
          { "name": "", "value_prop": "", "revenue_or_funding": "" }
        ]
      },
      "business": {
        "revenue_models": "",
        "recurring_pct": 0,
        "onetime_pct": 0,
        "customer_profile": "",
        "scalability": ""
      },
      "execution": {
        "time_to_mvp": "",
        "tech_feasibility_label": "",
        "tech_feasibility_context": "",
        "regulatory_risk_level": "",
        "regulatory_risk_context": "",
        "key_risk": "",
        "key_risk_highlight": ""
      }
    }

    ## Field-by-field instructions

    ### Top-level
    - project_name: A short, catchy brand-style name for the idea (not a description). Examples: "FreshFleet", "MediSync", "LoopPay".
    - summary: One sentence pitch — what the business does, for whom, and why it matters.
    - idea_score: 0-100 overall viability score. This MUST be the very last field you decide on — after completing ALL research and filling every other field. Review your entire analysis, form your own informed opinion on the idea's real potential, then assign a score. Weighted blend of market opportunity (30%), competitive landscape (20%), technical feasibility (25%), and execution risk (25%). BE DECISIVE AND OPINIONATED — do NOT default to safe middle scores. A truly great idea with strong market data and weak competition should score 80-95. A bad idea in a saturated market with high barriers should score 15-35. Use the full 0-100 range. Only genuinely average ideas should land in 45-65. Your score must reflect your honest expert judgment based on the research, not a hedged middle ground.

    ### Overview
    - market_stage_pill: MUST be exactly one of: "Emerging", "Growing", "Mature", "Declining". Displayed as a colored pill badge.
    - market_stage_label: A descriptive label like "Early Growth Phase" or "Pre-mainstream Adoption".
    - market_stage_context: One sentence explaining WHY this market is at that stage, citing a specific trend or data point. Wrap the 1-2 most important data points (numbers, percentages, dollar amounts) in <strong> tags.
    - competitive_intensity_dots: Integer 1-5. Displayed as filled/empty dots (3 = ●●●○○). 1 = blue ocean, 5 = hypercompetitive.
    - competitive_intensity_label: MUST be exactly one of: "Low", "Moderate", "High", "Very High".
    - competitive_intensity_context: One sentence about the competitive landscape — how many players, how entrenched, any moats. Wrap the 1-2 most important data points (numbers, player counts, key names) in <strong> tags.
    - project_feasibility: MUST be exactly one of: "Low", "Medium", "High".
    - project_feasibility_context: One sentence on whether this can realistically be built and launched — consider tech stack, team size, capital needed. Wrap the 1-2 most important data points (costs, timelines, team sizes) in <strong> tags.
    - positioning_sentence: How this idea differentiates from existing solutions. What is the unique angle or underserved niche.

    ### Market Size
    - tam: Total Addressable Market. Format as "$X.XB" or "$XXXM". Must come from real market research reports found via web search.
    - sam: Serviceable Addressable Market — the realistic slice this startup could target given geography, segment, and go-to-market. Same format.
    - market_stage: Same value as overview market_stage_pill.
    - key_driver: The single most important trend, technology shift, or behavioral change driving this market right now.
    - geo: Array of 3-5 geographic regions with their market share percentage. Each object has "region" (e.g. "North America", "Europe", "Asia-Pacific", "Latin America", "Middle East & Africa") and "pct" (integer, all pct values must sum to 100). Base the distribution on where the target market and demand are strongest.

    ### Competitors
    - intensity: Same value as overview competitive_intensity_label.
    - intensity_dots: Same value as overview competitive_intensity_dots.
    - competitor_count: Estimated total number of direct competitors in this space. Be realistic — include startups, incumbents, and adjacent players.
    - market_gap: One sentence describing the specific unserved need, underserved segment, or missing feature that this idea addresses.
    - top_3: MUST contain exactly 3 objects. Each must be a REAL company found via web search:
      - name: The actual company name.
      - value_prop: What that company does — their core product or service in one sentence.
      - revenue_or_funding: Real financial data. Format examples: "$10M ARR", "Series B $25M", "$50M revenue", "Bootstrapped ~$2M". If no data found, write "Undisclosed".

    ### Business Analytics
    - revenue_models: Comma-separated list of how this business makes money. Examples: "SaaS subscription", "marketplace commission", "freemium + premium", "API licensing", "advertising".
    - recurring_pct: Integer 0-100. What percentage of revenue would be recurring (subscriptions, retainers, renewals).
    - onetime_pct: Integer 0-100. MUST equal 100 - recurring_pct.
    - customer_profile: One sentence describing the ideal customer — their role, company size, industry, and pain point.
    - scalability: One sentence on how well this business scales — consider unit economics, marginal costs, network effects, geographic expansion.

    ### Execution
    - time_to_mvp: Realistic estimate for a small team (2-4 people). Format: "X-Y months".
    - tech_feasibility_label: MUST be exactly one of: "Low", "Medium", "High". Can this be built with existing, accessible technology?
    - tech_feasibility_context: One sentence on what core tech is needed, whether it's off-the-shelf or requires R&D, and key technical challenges.
    - regulatory_risk_level: MUST be exactly one of: "Low", "Medium", "High".
    - regulatory_risk_context: One sentence on relevant regulations, licensing requirements, compliance hurdles, or data privacy concerns.
    - key_risk: The single biggest threat to this business succeeding. Must be one sentence that naturally contains a short phrase worth highlighting.
    - key_risk_highlight: The exact substring (3-6 words) from key_risk that captures the core risk. This will be visually emphasized on the dashboard.

    ## Critical rules
    - Return ONLY valid JSON. No text before or after.
    - All string values must be filled — no empty strings.
    - Use real data from web search wherever possible. When exact figures are unavailable, provide educated estimates and note them as such.
    - top_3 must have exactly 3 real competitors with real names.
    - recurring_pct + onetime_pct must equal exactly 100.
    - key_risk_highlight must be an exact substring of key_risk.
  PROMPT

  CHAT_SYSTEM_PROMPT = <<~PROMPT
    You are a market research analyst preparing to validate a business idea.
Your goal is to collect the 2 most critical unknowns that would most improve the quality of your upcoming web research.

You will receive a raw business idea from a user. Based on what is already clear vs ambiguous in their description, you need to ask at most 2 questions — ONE AT A TIME — from these categories:

- Customer segment + geography: who specifically, and where
- Core problem being solved: what pain point, for what situation
- Revenue model intent: how does the business make money
- Technical/operational stage: what exists already, what needs to be built

## Conversation flow

You ask a maximum of 2 real questions. However, if the user gives a vague or unclear answer, you MUST ask a short clarification follow-up before moving on. Clarification follow-ups do NOT count toward the 2-question limit.

Here is how the flow works:

1. Ask your FIRST question. One short sentence. No preamble.
2. Read the user's answer:
   - If the answer is clear and usable → acknowledge briefly (max 5 words), then ask your SECOND question.
   - If the answer is too vague or ambiguous → ask a brief clarification follow-up (e.g. "Could you be more specific about X?"). Once clarified, acknowledge briefly and ask your SECOND question.
3. Read the user's answer to the second question:
   - If the answer is clear and usable → reply with EXACTLY: [RESEARCH_READY]
   - If the answer is too vague or ambiguous → ask a brief clarification follow-up. Once clarified, reply with EXACTLY: [RESEARCH_READY]

## Question rules

- Each question must target a DIFFERENT category — never ask two questions from the same dimension
- Never ask about something already clear from the idea description
- Make questions specific and bounded — avoid presenting only 2 options when more possibilities exist
- Each question should directly unlock a research dimension: market sizing, competitor search, feasibility scoring, or revenue modeling
- Clarification follow-ups must be short (one sentence) and directly reference what was unclear in the user's previous answer
- No filler phrases ("Great question", "Thanks for sharing", "Interesting idea")
- Plain text only — no JSON, no markdown, no bullet points
  PROMPT

  def initialize(chat)
    @chat = chat
    @business_idea = chat.business_idea
  end

  def ask
    llm_chat = RubyLLM.chat(model: "claude-sonnet-4-20250514").with_instructions("#{CHAT_SYSTEM_PROMPT}\n\nThe business idea: #{@business_idea.content}")

    # Replay full message history without triggering API calls
    messages = @chat.messages.order(:created_at)
    if messages.any?
      messages.each do |m|
        llm_chat.add_message(role: m.role.to_sym, content: m.content)
      end
    else
      # First call — send the idea as the initial user message
      llm_chat.add_message(role: :user, content: "Here is my business idea: #{@business_idea.content}")
    end

    # Trigger a single API call with the full history
    response = llm_chat.complete
    response.content || "Sorry, I couldn't generate a response."
  rescue => e
    Rails.logger.error("ClaudeService#ask error: #{e.message}")
    "Sorry, I encountered an error. Please try again."
  end

  def research
    conversation = build_conversation_context
    user_message = "Here is the business idea and the clarifying conversation:\n\n" \
                   "IDEA: #{@business_idea.content}\n\n" \
                   "CONVERSATION:\n#{conversation}\n\n" \
                   "Now research this idea using web search and return the JSON."

    body = {
      model: "claude-haiku-4-5-20251001",
      max_tokens: 16_000,
      system: RESEARCH_SYSTEM_PROMPT,
      tools: [{ type: "web_search_20250305", name: "web_search", max_uses: 5 }],
      messages: [{ role: "user", content: user_message }]
    }

    uri = URI(ANTHROPIC_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 300

    request = Net::HTTP::Post.new(uri)
    request["content-type"] = "application/json"
    request["x-api-key"] = ENV["ANTHROPIC_API_KEY"]
    request["anthropic-version"] = "2023-06-01"
    request.body = body.to_json

    response = http.request(request)
    Rails.logger.info("ClaudeService#research HTTP status: #{response.code}")
    result = JSON.parse(response.body)
    Rails.logger.info("ClaudeService#research stop_reason: #{result['stop_reason']}")
    Rails.logger.info("ClaudeService#research content types: #{result['content']&.map { |b| b['type'] }&.inspect}")

    if result["error"]
      Rails.logger.error("ClaudeService#research API error: #{result['error']}")
      raise "Claude API error: #{result['error']['message']}"
    end

    text = extract_text_from_response(result)
    Rails.logger.info("ClaudeService#research extracted text length: #{text.length}")
    Rails.logger.info("ClaudeService#research text preview: #{text[0..500]}")
    parse_research_json(text)
  end

  private

  def build_conversation_context
    @chat.messages.order(:created_at).map do |m|
      "#{m.role.upcase}: #{m.content}"
    end.join("\n")
  end

  def extract_text_from_response(result)
    result["content"]
      .select { |block| block["type"] == "text" }
      .map { |block| block["text"] }
      .join
  end

  def parse_research_json(text)
    clean = text.gsub(/<cite[^>]*>/, "") # strip <cite> tags from web_search
    clean = clean.gsub(%r{</cite>}, "")

    # Extract JSON from ```json fences if present (handles preamble text before the JSON)
    if clean =~ /```json\s*(.*?)```/m
      clean = $1.strip
    else
      # Fallback: find the first { to last } as the JSON object
      start_idx = clean.index("{")
      end_idx = clean.rindex("}")
      if start_idx && end_idx
        clean = clean[start_idx..end_idx]
      end
    end

    JSON.parse(clean)
  end
end
