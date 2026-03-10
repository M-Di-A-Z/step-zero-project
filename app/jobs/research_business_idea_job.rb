class ResearchBusinessIdeaJob < ApplicationJob
  queue_as :default

  def perform(business_idea_id)
    business_idea = BusinessIdea.find(business_idea_id)
    # TODO: Call ClaudeService to research the idea and populate business_data
    # Example:
    # result = ClaudeService.new(business_idea).research
    # business_idea.update!(title: result["project_name"], ...)
    business_idea.update!(status: "complete")
  end
end
