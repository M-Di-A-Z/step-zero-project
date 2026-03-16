# Clean up existing data
Like.destroy_all
Comment.destroy_all
Message.destroy_all
Chat.destroy_all
BusinessData.destroy_all
BusinessIdea.destroy_all
User.destroy_all

# ── Profile pictures ──────────────────────────────────────────
PP_DIR = Rails.root.join("app", "assets", "images", "ppseed")
pp_files = Dir.glob(PP_DIR.join("*.png")).sort

# ── Seed users ────────────────────────────────────────────────
SEED_USERS = [
  { first_name: "Alex",      last_name: "Martin",    email: "demo@ideaproof.com",     password: "password123" },
  { first_name: "Test",      last_name: "User",      email: "test@test.com",           password: "123456" },
  { first_name: "Sophie",    last_name: "Durand",    email: "sophie.durand@mail.com",  password: "password123" },
  { first_name: "Lucas",     last_name: "Bernard",   email: "lucas.bernard@mail.com",  password: "password123" },
  { first_name: "Emma",      last_name: "Petit",     email: "emma.petit@mail.com",     password: "password123" },
  { first_name: "Hugo",      last_name: "Moreau",    email: "hugo.moreau@mail.com",    password: "password123" },
  { first_name: "Léa",       last_name: "Laurent",   email: "lea.laurent@mail.com",    password: "password123" },
  { first_name: "Nathan",    last_name: "Garcia",    email: "nathan.garcia@mail.com",  password: "password123" },
  { first_name: "Chloé",     last_name: "Roux",      email: "chloe.roux@mail.com",     password: "password123" },
  { first_name: "Julien",    last_name: "Fournier",  email: "julien.fournier@mail.com", password: "password123" },
  { first_name: "Camille",   last_name: "Girard",    email: "camille.girard@mail.com",  password: "password123" },
  { first_name: "Thomas",    last_name: "Bonnet",    email: "thomas.bonnet@mail.com",   password: "password123" },
]

users = SEED_USERS.each_with_index.map do |attrs, i|
  user = User.create!(
    email: attrs[:email],
    password: attrs[:password],
    password_confirmation: attrs[:password],
    first_name: attrs[:first_name],
    last_name: attrs[:last_name]
  )
  if pp_files[i]
    user.avatar.attach(
      io: File.open(pp_files[i]),
      filename: File.basename(pp_files[i]),
      content_type: "image/png"
    )
  end
  user
end

demo_user = users[0]
test_user = users[1]

# ── Seed business ideas ───────────────────────────────────────
IDEAS = [
  {
    title: "NutriScan",
    content: "An app that scans food labels with your phone camera and instantly tells you if the product matches your dietary goals and health restrictions.",
    summary: "NutriScan turns any smartphone into a personal nutrition advisor — just scan, and know exactly what you're eating.",
    idea_score: 74, status: "complete",
    details: "Target users are health-conscious millennials and people managing chronic conditions like diabetes or food allergies."
  },
  {
    title: "UrbanNest",
    content: "A platform connecting urban dwellers with verified local hosts who rent out quiet co-working spots inside their homes.",
    summary: "UrbanNest transforms underused home spaces into on-demand co-working spots for remote workers who need a quiet place to focus.",
    idea_score: 61, status: "complete",
    details: "Target users are remote workers and freelancers in dense cities."
  },
  {
    title: "PetLoop",
    content: "A neighborhood-based app that connects pet owners for shared walks, pet-sitting exchanges, and emergency vet recommendations.",
    summary: "PetLoop builds a trusted local network so pet owners never face a pet emergency or vacation alone.",
    idea_score: 58, status: "complete",
    details: "Focused on dog and cat owners in urban and suburban neighborhoods."
  },
  {
    title: "GreenRoute",
    content: "A navigation app that prioritizes the most eco-friendly route — lowest emissions, most bike lanes, best public transit combos.",
    summary: "GreenRoute helps you get anywhere with the smallest carbon footprint possible.",
    idea_score: 82, status: "complete",
    details: "Combines public transit APIs, bike infrastructure data, and carbon calculators."
  },
  {
    title: "SkillSwap",
    content: "A platform where freelancers trade skills instead of money — a designer does your branding in exchange for accounting help.",
    summary: "SkillSwap lets freelancers barter expertise, eliminating cash barriers for early-stage solopreneurs.",
    idea_score: 45, status: "complete",
    details: "Uses a time-credit system to keep exchanges fair."
  },
  {
    title: "MealMate",
    content: "An app that generates weekly meal plans based on what's already in your fridge, reducing food waste and grocery bills.",
    summary: "MealMate turns your leftovers into a full week of recipes — no waste, no stress.",
    idea_score: 69, status: "complete",
    details: "Computer vision identifies fridge contents; recipe engine adapts to dietary preferences."
  },
  {
    title: "QuietHour",
    content: "A focus-timer app that silences notifications, blocks distracting apps, and tracks deep-work streaks over time.",
    summary: "QuietHour protects your focus time and gamifies deep work with streaks and stats.",
    idea_score: 53, status: "complete",
    details: "Integrates with calendar apps to auto-schedule focus blocks."
  },
  {
    title: "LocalBrew",
    content: "A discovery platform for independent coffee roasters, letting users subscribe to monthly curated beans from local micro-roasteries.",
    summary: "LocalBrew connects coffee lovers directly with small-batch roasters in their city.",
    idea_score: 66, status: "complete",
    details: "Subscription model with rotating selections and tasting notes."
  },
  {
    title: "FixItNow",
    content: "An on-demand marketplace for small home repairs — leaky faucets, broken shelves, stuck doors — with vetted local handypeople.",
    summary: "FixItNow gets small home repairs done in hours, not weeks, with trusted local pros.",
    idea_score: 71, status: "complete",
    details: "Flat-rate pricing for common repairs; background-checked providers."
  },
  {
    title: "StudyPod",
    content: "A platform that matches university students into small accountability study groups based on courses, schedules, and learning styles.",
    summary: "StudyPod fights academic isolation by building smart, compatible study groups automatically.",
    idea_score: 48, status: "complete",
    details: "Integrates with university course catalogs and calendar systems."
  },
  {
    title: "WanderList",
    content: "A travel planning app where locals curate secret itineraries — hidden restaurants, viewpoints, and experiences tourists never find.",
    summary: "WanderList gives travelers access to insider itineraries curated by real locals.",
    idea_score: 77, status: "complete",
    details: "Locals earn commissions on bookings made through their curated lists."
  },
  {
    title: "FreshDrop",
    content: "A same-day delivery service connecting small organic farms directly to urban consumers, cutting out supermarket middlemen.",
    summary: "FreshDrop brings farm-fresh organic produce to your door within hours of harvest.",
    idea_score: 63, status: "complete",
    details: "Partners with farms within 100km radius; optimized delivery routes."
  },
  {
    title: "SoundNest",
    content: "A platform for independent musicians to sell stems, loops, and beats directly to producers and content creators.",
    summary: "SoundNest is a marketplace where indie musicians monetize their raw sounds and loops.",
    idea_score: 55, status: "complete",
    details: "Built-in audio preview, licensing tiers, and royalty tracking."
  },
  {
    title: "CareCircle",
    content: "A coordination app for families managing elderly care — shared calendars, medication reminders, and caregiver task assignments.",
    summary: "CareCircle helps families organize elderly care without the chaos of group chats and spreadsheets.",
    idea_score: 84, status: "complete",
    details: "HIPAA-aware design; integrates with pharmacy and doctor appointment systems."
  },
  {
    title: "ReStyled",
    content: "A second-hand fashion app focused on curated bundles — users sell outfit sets, not individual pieces, for a styled thrift experience.",
    summary: "ReStyled makes second-hand shopping feel like getting a personal stylist, not digging through bins.",
    idea_score: 70, status: "complete",
    details: "AI-powered style matching based on user preferences and body type."
  },
]

# ── Business data template ────────────────────────────────────
def build_business_data(idea)
  BusinessData.create!(
    business_idea: idea,
    overview: {
      market_stage_pill: ["Emerging", "Growing", "Mature"].sample,
      market_stage_label: "#{["Early", "Mid", "Late"].sample} Stage",
      market_stage_context: "This market is evolving with increasing consumer demand and technological maturity.",
      competitive_intensity_dots: rand(1..5),
      competitive_intensity_label: ["Low", "Moderate", "High"].sample + " Competition",
      competitive_intensity_context: "The competitive landscape presents both opportunities and challenges for new entrants.",
      project_feasibility: ["High", "Medium", "Low"].sample,
      project_feasibility_context: "Technical feasibility depends on available APIs and infrastructure in the target market.",
      positioning_sentence: "#{idea.title} addresses a clear gap in the current market with a differentiated approach."
    },
    market_size: {
      tam: "$#{rand(5..50)}B",
      sam: "$#{rand(1..8)}B",
      market_stage: ["Emerging", "Early Growth", "Growth", "Mature"].sample,
      key_driver: "Shifting consumer behavior and digital adoption are the primary growth catalysts.",
      geo: [
        { region: "North America", pct: rand(30..45) },
        { region: "Europe", pct: rand(20..35) },
        { region: "Asia-Pacific", pct: rand(15..25) },
        { region: "Rest of World", pct: rand(5..15) }
      ]
    },
    competitors: {
      intensity: ["Low", "Moderate", "High"].sample,
      intensity_dots: rand(1..5),
      competitor_count: rand(3..20),
      market_gap: "No existing solution fully addresses the specific user need that #{idea.title} targets.",
      top_3: [
        { name: "Competitor A", value_prop: "Broad market coverage with generic features", revenue_or_funding: "$#{rand(1..50)}M" },
        { name: "Competitor B", value_prop: "Niche player with limited geographic reach", revenue_or_funding: "$#{rand(1..30)}M" },
        { name: "Competitor C", value_prop: "Enterprise-focused solution with high price point", revenue_or_funding: "$#{rand(5..100)}M" }
      ]
    },
    business: {
      revenue_models: "Freemium subscription model with premium tiers, plus B2B partnerships and affiliate revenue streams.",
      recurring_pct: rand(40..80),
      onetime_pct: rand(20..60),
      customer_profile: "Digitally-savvy adults aged 25–45 looking for modern solutions to everyday problems.",
      scalability: "#{["High", "Moderate", "Low"].sample} scalability potential based on the product's digital-first architecture."
    },
    execution: {
      time_to_mvp: "#{rand(2..6)} months",
      tech_feasibility_label: ["High", "Medium"].sample,
      tech_feasibility_context: "The core technology stack is well-established with available open-source components.",
      regulatory_risk_level: ["Low", "Medium", "High"].sample,
      regulatory_risk_context: "Regulatory considerations are manageable with proper legal guidance in target markets.",
      key_risk: "User acquisition and retention in a competitive landscape remain the primary execution risks.",
      key_risk_highlight: "user acquisition in competitive market"
    }
  )
end

# Create all ideas, share them, and build data
ideas = IDEAS.each_with_index.map do |attrs, i|
  owner = users[i % users.size]
  idea = BusinessIdea.create!(
    user: owner,
    title: attrs[:title],
    content: attrs[:content],
    summary: attrs[:summary],
    idea_score: attrs[:idea_score],
    status: attrs[:status],
    details: attrs[:details],
    shared: true,
    report_generated: true
  )
  build_business_data(idea)
  idea
end

# ── Seed likes ────────────────────────────────────────────────
ideas.each do |idea|
  likers = users.reject { |u| u == idea.user }.sample(rand(1..8))
  likers.each do |user|
    Like.create!(user: user, business_idea: idea)
  end
end

# ── Seed comments ─────────────────────────────────────────────
COMMENTS = [
  "Love this idea! The market timing feels right.",
  "Have you considered partnering with existing platforms for distribution?",
  "The score seems a bit low — I think there's more potential here.",
  "This solves a real pain point. Would definitely use it.",
  "Interesting concept, but what about regulatory hurdles?",
  "The competitive landscape section is really insightful.",
  "How would you handle user acquisition in the early days?",
  "Great positioning. The differentiator is clear.",
  "I'd be curious to see a prototype of this.",
  "This reminds me of a Y Combinator pitch — solid fundamentals.",
  "What's the monetization timeline looking like?",
  "Really clean idea. Simple but powerful.",
  "Would love to see more data on the target demographic.",
  "The TAM feels optimistic — any sources for that?",
  "Super compelling. Shared this with my co-founder.",
]

ideas.each do |idea|
  commenters = users.reject { |u| u == idea.user }.sample(rand(0..6))
  commenters.each do |user|
    Comment.create!(
      user: user,
      business_idea: idea,
      body: COMMENTS.sample,
      created_at: rand(1..14).days.ago
    )
  end
end

puts "✓ Seed complete!"
puts "  #{User.count} users"
puts "  #{BusinessIdea.count} business ideas (all shared)"
puts "  #{Like.count} likes"
puts "  #{Comment.count} comments"
puts ""
puts "  Demo login: demo@ideaproof.com / password123"
puts "  Test login: test@test.com / 123456"
