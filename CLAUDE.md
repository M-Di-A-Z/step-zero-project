# IdeaProof — AI Idea Validation Tool

## Stack
- Ruby on Rails backend
- HTML + ERB views, plain CSS (no React, no JS frameworks)
- PostgreSQL with jsonb columns
- Anthropic Claude API (claude-sonnet-4-20250514) + web_search tool
- Devise for auth
- Sidekiq for background jobs

## App Flow
1. Landing page → user inputs raw idea → creates business_ideas record (status: pending)
2. Chat screen → AI asks 3 clarifying questions inline → saves features + target_market
3. Background job → AI researches web → returns one JSON blob → split into DB columns
4. 5 tabbed dashboards rendered from DB

## DB Structure

### business_ideas (flat columns)
- content (text)            # raw user input
- title (string)            # from AI
- summary (text)            # from AI
- idea_score (integer)      # from AI — queryable
- features (text)           # from clarifying questions
- target_market (text)      # from clarifying questions
- status (string)           # pending / researching / complete
- user_id (foreign key)

### business_data (jsonb columns — one row per idea)
- overview      (jsonb)
- market_size   (jsonb)
- competitors   (jsonb)
- business      (jsonb)
- execution     (jsonb)
- business_idea_id (foreign key)

### messages
- content (text)
- role (string)             # user / assistant
- chat_id (foreign key)

### chats
- business_idea_id (foreign key)

---

## Screen-by-Screen Data Map

### Landing Page
Static. On submit → creates business_ideas with content + status: pending. No DB reads.

### Chat Screen (Clarifying Questions)
Writes only:
- business_ideas.features
- business_ideas.target_market
- messages (each Q&A exchange with role)

### Dashboard 1 — Overview
Reads from business_ideas + business_data.overview

| Field on screen             | Source                  | JSON key                        |
|-----------------------------|-------------------------|---------------------------------|
| Project name                | business_ideas.title    | —                               |
| Summary sentence            | business_ideas.summary  | —                               |
| Idea Score number           | business_ideas.idea_score | —                             |
| Card 1 — Market Stage pill  | business_data.overview  | market_stage_pill               |
| Card 1 — Stage label        | business_data.overview  | market_stage_label              |
| Card 1 — Context sentence   | business_data.overview  | market_stage_context            |
| Card 2 — Intensity dot bar  | business_data.overview  | competitive_intensity_dots      |
| Card 2 — Intensity label    | business_data.overview  | competitive_intensity_label     |
| Card 2 — Context sentence   | business_data.overview  | competitive_intensity_context   |
| Card 3 — Feasibility label  | business_data.overview  | project_feasibility             |
| Card 3 — Context sentence   | business_data.overview  | project_feasibility_context     |
| Positioning sentence        | business_data.overview  | positioning_sentence            |

### Dashboard 2 — Market Size
Reads from business_data.market_size

| Field on screen        | JSON key      |
|------------------------|---------------|
| TAM number             | tam           |
| SAM number             | sam           |
| Market Stage label     | market_stage  |
| Key market driver      | key_driver    |

### Dashboard 3 — Competitors
Reads from business_data.competitors

| Field on screen          | JSON key                      |
|--------------------------|-------------------------------|
| Intensity dot bar        | intensity_dots                |
| Intensity label          | intensity                     |
| Competitor count         | competitor_count              |
| Market gap sentence      | market_gap                    |
| Table — name             | top_3[n].name                 |
| Table — value prop       | top_3[n].value_prop           |
| Table — revenue/funding  | top_3[n].revenue_or_funding   |

### Dashboard 4 — Business Analytics
Reads from business_data.business

| Field on screen          | JSON key          |
|--------------------------|-------------------|
| Revenue models           | revenue_models    |
| Recurring %              | recurring_pct     |
| One-time %               | onetime_pct       |
| Customer profile         | customer_profile  |
| Scalability sentence     | scalability       |

### Dashboard 5 — Execution
Reads from business_data.execution

| Field on screen              | JSON key                    |
|------------------------------|-----------------------------|
| Key risk sentence            | key_risk                    |
| Key risk highlighted phrase  | key_risk_highlight          |
| Time to MVP                  | time_to_mvp                 |
| Tech feasibility label       | tech_feasibility_label      |
| Tech feasibility context     | tech_feasibility_context    |
| Regulatory risk pill         | regulatory_risk_level       |
| Regulatory risk context      | regulatory_risk_context     |

---

## AI JSON Structure (strict — no extra fields)

AI must return this exact JSON. No markdown, no preamble, no ```json fences.

```json
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
    "key_driver": ""
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
```

---

## Saving AI Response in Rails

```ruby
parsed = JSON.parse(ai_response)

idea.update!(
  title:      parsed["project_name"],
  summary:    parsed["summary"],
  idea_score: parsed["idea_score"]
)

idea.business_datum.update!(
  overview:    parsed["overview"].to_json,
  market_size: parsed["market"].to_json,
  competitors: parsed["competitors"].to_json,
  business:    parsed["business"].to_json,
  execution:   parsed["execution"].to_json
)
```

Always rescue JSON::ParserError. Always strip ```json fences before parsing.

---

## Design System

| Property       | Value                          |
|----------------|--------------------------------|
| Background     | #F5F0E8 warm cream/beige       |
| Primary text   | #1a1a1a near-black             |
| Accent         | #8B2500 rust/red italic        |
| Cards          | No fill — border: 1px solid #E0D9CE |
| Headlines      | Large bold editorial           |
| Labels         | Small gray uppercase           |
| Dot bars       | ●●●○○ filled/empty dots        |
| Pills          | yellow=Growing, red=High, green=Low, orange=Medium |
| Layout         | Asymmetric grid                |
| Feel           | Newspaper/editorial — NOT SaaS, NOT lavender |

## Navigation
- Bottom tab bar: 5 yellow sticky-note cards
- Tabs: Dashboard | Market size | Competitors | Business | Execution
- Active tab: raised + purple pill label top-left
- Left/right arrows for sequential navigation

## Key Rules
- Never expose API key to frontend
- All Claude API calls via ClaudeService only
- Always rescue JSON::ParserError
- Strip ```json fences before parsing AI response
- Store all AI results in DB — never re-run if data already exists
- Use background jobs for AI research step (avoid request timeout)
- Poll for completion from frontend via JS interval on status endpoint
