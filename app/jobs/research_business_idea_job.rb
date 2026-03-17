class ResearchBusinessIdeaJob < ApplicationJob
  queue_as :default

  def perform(business_idea_id)
    business_idea = BusinessIdea.find(business_idea_id)
    chat = business_idea.chat
    parsed = ClaudeService.new(chat).research

    business_idea.update!(
      title: parsed["project_name"],
      summary: parsed["summary"],
      idea_score: parsed["idea_score"],
      status: "complete"
    )

    data = business_idea.business_data || business_idea.create_business_data!
    data.update!(
      overview: parsed["overview"].to_json,
      market_size: parsed["market"].to_json,
      competitors: parsed["competitors"].to_json,
      business: parsed["business"].to_json,
      execution: parsed["execution"].to_json,
      launch_plan: parsed["launch_plan"].to_json
    )
  rescue JSON::ParserError => e
    Rails.logger.error("ResearchBusinessIdeaJob JSON parse error: #{e.message}")
    business_idea.update!(status: "aborted")
  rescue => e
    Rails.logger.error("ResearchBusinessIdeaJob error: #{e.message}")
    business_idea.update!(status: "aborted")
  end
end
