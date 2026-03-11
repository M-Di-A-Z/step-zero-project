# Clean up existing data
Message.destroy_all
Chat.destroy_all
BusinessData.destroy_all
BusinessIdea.destroy_all
User.destroy_all

# Create a demo user
user = User.create!(
  email: "demo@ideaproof.com",
  password: "password123",
  password_confirmation: "password123"
)

# Create a business idea
idea = BusinessIdea.create!(
  user: user,
  title: "NutriScan",
  content: "An app that scans food labels with your phone camera and instantly tells you if the product matches your dietary goals and health restrictions.",
  summary: "NutriScan turns any smartphone into a personal nutrition advisor — just scan, and know exactly what you're eating.",
  idea_score: 74,
  status: "complete",
  details: "Target users are health-conscious millennials and people managing chronic conditions like diabetes or food allergies. Core features include barcode scanning, ingredient analysis, and personalized dietary profiles."
)

# Create associated business_data
BusinessData.create!(
  business_idea: idea,
  overview: {
    market_stage_pill: "Growing",
    market_stage_label: "Early Growth Stage",
    market_stage_context: "Consumer health tech is expanding rapidly, with rising demand for personalized nutrition tools driven by wellness trends.",
    competitive_intensity_dots: 3,
    competitive_intensity_label: "Moderate Competition",
    competitive_intensity_context: "Several apps exist in this space, but most lack deep personalization or real-time ingredient analysis for complex dietary needs.",
    project_feasibility: "High",
    project_feasibility_context: "Core tech stack is accessible — barcode APIs and nutrition databases are publicly available, keeping build complexity low.",
    positioning_sentence: "NutriScan is the first nutrition scanner built around your health profile, not just generic labels."
  },
  market_size: {
    tam: "$28B",
    sam: "$4.2B",
    market_stage: "Early Growth",
    key_driver: "Growing prevalence of diet-related chronic diseases and consumer shift toward preventive health management."
  },
  competitors: {
    intensity: "Moderate",
    intensity_dots: 3,
    competitor_count: 12,
    market_gap: "No leading app combines real-time ingredient scanning with condition-specific dietary profiles in a single seamless flow.",
    top_3: [
      { name: "Yuka", value_prop: "Product scoring based on additives and nutritional quality", revenue_or_funding: "$6M ARR" },
      { name: "MyFitnessPal", value_prop: "Calorie tracking and macro logging with large food database", revenue_or_funding: "Acquired for $475M" },
      { name: "Open Food Facts", value_prop: "Open-source food product database with community contributions", revenue_or_funding: "Non-profit, donor funded" }
    ]
  },
  business: {
    revenue_models: "Freemium subscription ($4.99/mo for premium profiles), B2B API licensing to dietitian platforms, and affiliate partnerships with health food brands.",
    recurring_pct: 70,
    onetime_pct: 30,
    customer_profile: "Health-conscious adults aged 25–45 managing specific dietary needs, food allergies, or chronic conditions such as diabetes and IBS.",
    scalability: "High scalability potential — core logic is software-based and the product can expand internationally with minimal marginal cost per new user."
  },
  execution: {
    time_to_mvp: "3–4 months",
    tech_feasibility_label: "High",
    tech_feasibility_context: "Leverages existing barcode scanning SDKs and open nutrition APIs (Open Food Facts, USDA). No proprietary hardware required.",
    regulatory_risk_level: "Low",
    regulatory_risk_context: "No medical claims are made — the app provides informational guidance only, keeping it outside FDA regulated territory.",
    key_risk: "User retention drops sharply if the food database lacks coverage for local or international products outside major Western markets.",
    key_risk_highlight: "database coverage gap for non-Western markets"
  }
)

# Create a test user
test_user = User.create!(
  email: "test@test.com",
  password: "123456",
  password_confirmation: "123456"
)

# Create a business idea for test user
test_idea = BusinessIdea.create!(
  user: test_user,
  title: "UrbanNest",
  content: "A platform connecting urban dwellers with verified local hosts who rent out quiet co-working spots inside their homes or apartments.",
  summary: "UrbanNest transforms underused home spaces into on-demand co-working spots for remote workers who need a quiet place to focus.",
  idea_score: 61,
  status: "complete",
  details: "Target users are remote workers and freelancers in dense cities who struggle with noisy home environments or expensive co-working memberships. Key features include host verification, real-time availability, and per-hour booking."
)

# Create associated business_data for test user
BusinessData.create!(
  business_idea: test_idea,
  overview: {
    market_stage_pill: "Emerging",
    market_stage_label: "Early Stage",
    market_stage_context: "The peer-to-peer workspace market is nascent but gaining traction as hybrid work becomes the norm in major cities.",
    competitive_intensity_dots: 2,
    competitive_intensity_label: "Low Competition",
    competitive_intensity_context: "Few direct competitors target home-based micro co-working — most platforms focus on dedicated office spaces or desk rentals.",
    project_feasibility: "Medium",
    project_feasibility_context: "Host acquisition and trust-building require significant effort, and liability/insurance considerations add operational complexity.",
    positioning_sentence: "UrbanNest is the Airbnb for quiet focus — affordable, local, and human-scale co-working inside real homes."
  },
  market_size: {
    tam: "$12B",
    sam: "$1.8B",
    market_stage: "Emerging",
    key_driver: "Permanent shift to hybrid and remote work creating sustained demand for flexible, affordable third-place workspaces."
  },
  competitors: {
    intensity: "Low",
    intensity_dots: 2,
    competitor_count: 5,
    market_gap: "No platform currently offers verified, bookable co-working inside private homes at an hourly rate in residential neighborhoods.",
    top_3: [
      { name: "Breather", value_prop: "On-demand private meeting rooms in commercial buildings", revenue_or_funding: "Raised $120M, shut down 2020" },
      { name: "Spacious", value_prop: "Repurposed restaurant spaces as daytime co-working spots", revenue_or_funding: "Acquired by WeWork 2019" },
      { name: "Neighbor", value_prop: "Peer-to-peer storage rental in unused home spaces", revenue_or_funding: "$53M raised" }
    ]
  },
  business: {
    revenue_models: "Commission on each booking (15–20%), optional host subscription for premium listing placement, and corporate team packages for distributed companies.",
    recurring_pct: 40,
    onetime_pct: 60,
    customer_profile: "Remote workers and freelancers aged 25–40 in dense urban areas who need occasional quiet focus time outside their home.",
    scalability: "Moderate scalability — growth is tied to host supply in each city, requiring localized expansion rather than purely digital scaling."
  },
  execution: {
    time_to_mvp: "4–6 months",
    tech_feasibility_label: "Medium",
    tech_feasibility_context: "Core booking and payments infrastructure is well-understood, but host onboarding flows and real-time availability syncing add complexity.",
    regulatory_risk_level: "Medium",
    regulatory_risk_context: "Short-term subletting may conflict with local lease agreements or zoning laws, requiring careful legal framing in each target city.",
    key_risk: "Host supply is the critical bottleneck — without enough verified hosts in a given neighborhood, the product fails to deliver consistent availability.",
    key_risk_highlight: "host supply bottleneck by neighborhood"
  }
)

puts "Seed complete — user: demo@ideaproof.com / password: password123"
puts "BusinessIdea: #{idea.title} (id: #{idea.id})"
puts "Seed complete — user: test@test.com / password: 123456"
puts "BusinessIdea: #{test_idea.title} (id: #{test_idea.id})"
