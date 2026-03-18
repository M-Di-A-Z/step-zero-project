# Strategic Bold in Dashboard Cards — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add AI-applied strategic `<strong>` bolding (max 2 per field) to 10 body-text fields across the dashboard, and fix the execution tab which currently strips all HTML.

**Architecture:** Two layers of changes — (1) the `RESEARCH_SYSTEM_PROMPT` constant in `ClaudeService` is updated to instruct the AI to output `<strong>` tags in target fields; (2) ERB partials are updated to call `sanitize(value, tags: %w[strong])` instead of raw `<%= value %>` or the current HTML-stripping `.gsub` pattern. No new files. No DB migration.

**Tech Stack:** Ruby on Rails 7, ERB, Minitest, Anthropic API

---

## File Map

| File | Change |
|------|--------|
| `app/services/claude_service.rb` | Update `RESEARCH_SYSTEM_PROMPT` — 4 edits (overview max-2, 4 plain fields, 2 execution fields, key_risk switch) |
| `app/views/business_ideas/_market_size.html.erb` | `key_driver` → `sanitize` |
| `app/views/business_ideas/_competitors.html.erb` | `market_gap` → `sanitize` |
| `app/views/business_ideas/_business.html.erb` | `customer_profile`, `scalability` → `sanitize` |
| `app/views/business_ideas/_execution.html.erb` | `tech_feasibility_context`, `regulatory_risk_context`, `key_risk` → `sanitize`, remove gsub+key_risk_highlight |
| `test/helpers/bold_sanitize_test.rb` | New: unit tests verifying `sanitize` passes `<strong>` and strips other tags |

---

## Task 1: Prompt — add max-2 rule to 3 overview fields

**Files:**
- Modify: `app/services/claude_service.rb:115-120`

The three overview context fields already have `<strong>` instructions. Add the max-2 enforcement sentence to each.

- [ ] **Step 1: Open `app/services/claude_service.rb` and locate the overview field instructions**

Find lines containing `market_stage_context`, `competitive_intensity_context`, and `project_feasibility_context` instructions (around lines 115–120). Each ends with a `HARD LIMIT` sentence about character count.

- [ ] **Step 2: Append the max-2 rule to each of the three fields**

For `market_stage_context` (line ~115), the current instruction ends with:
```
HARD LIMIT: the plain text content (excluding any HTML tags like <strong></strong>) must be ≤ 300 characters with spaces. Count before writing, shorten if needed.
```

Add immediately after (same line or new sentence):
```
Maximum 2 <strong> elements — if you bold more, remove the least important ones.
```

Apply the same addition to `competitive_intensity_context` and `project_feasibility_context`.

- [ ] **Step 3: Verify the three lines look correct**

Each of the three field instructions should now contain both:
- `HARD LIMIT: the plain text content ... must be ≤ 300 characters`
- `Maximum 2 <strong> elements — if you bold more, remove the least important ones.`

- [ ] **Step 4: Commit**

```bash
git add app/services/claude_service.rb
git commit -m "feat: enforce max-2 bold rule on overview context fields"
```

---

## Task 2: Prompt — add `<strong>` instructions to 4 plain-text fields

**Files:**
- Modify: `app/services/claude_service.rb` (Market Size, Competitors, Business sections)

Fields: `key_driver`, `market_gap`, `customer_profile`, `scalability`. These currently have no bold instruction at all.

- [ ] **Step 1: Locate `key_driver` instruction** (around line 127)

Current text:
```
- key_driver: The single most important trend, technology shift, or behavioral change driving this market right now.
```

Replace with:
```
- key_driver: The single most important trend, technology shift, or behavioral change driving this market right now. Wrap at most 2 key data points, phrases, or facts in <strong> tags. Strategic use only — if nothing clearly warrants emphasis, use no bold. Maximum 2 <strong> elements.
```

- [ ] **Step 2: Locate `market_gap` instruction** (around line 134)

Current text:
```
- market_gap: One sentence describing the specific unserved need, underserved segment, or missing feature that this idea addresses.
```

Replace with:
```
- market_gap: One sentence describing the specific unserved need, underserved segment, or missing feature that this idea addresses. Wrap at most 2 key data points, phrases, or facts in <strong> tags. Strategic use only — if nothing clearly warrants emphasis, use no bold. Maximum 2 <strong> elements.
```

- [ ] **Step 3: Locate `customer_profile` instruction** (around line 143)

Current text:
```
- customer_profile: One sentence describing the ideal customer — their role, company size, industry, and pain point.
```

Replace with:
```
- customer_profile: One sentence describing the ideal customer — their role, company size, industry, and pain point. Wrap at most 2 key data points, phrases, or facts in <strong> tags. Strategic use only — if nothing clearly warrants emphasis, use no bold. Maximum 2 <strong> elements.
```

- [ ] **Step 4: Locate `scalability` instruction** (around line 144)

Current text:
```
- scalability: One sentence on how well this business scales — consider unit economics, marginal costs, network effects, geographic expansion.
```

Replace with:
```
- scalability: One sentence on how well this business scales — consider unit economics, marginal costs, network effects, geographic expansion. Wrap at most 2 key data points, phrases, or facts in <strong> tags. Strategic use only — if nothing clearly warrants emphasis, use no bold. Maximum 2 <strong> elements.
```

- [ ] **Step 5: Commit**

```bash
git add app/services/claude_service.rb
git commit -m "feat: add strategic bold instructions to key_driver, market_gap, customer_profile, scalability"
```

---

## Task 3: Prompt — add `<strong>` + char cap to 2 execution sentence fields

**Files:**
- Modify: `app/services/claude_service.rb` (Execution section, lines ~149-152)

Fields: `tech_feasibility_context`, `regulatory_risk_context`. These need bold instructions AND a 300-char cap (the view's `.truncate(320)` safety net is being removed in Task 7).

- [ ] **Step 1: Locate `tech_feasibility_context` instruction** (around line 150)

Current text:
```
- tech_feasibility_context: One sentence on what core tech is needed, whether it's off-the-shelf or requires R&D, and key technical challenges.
```

Replace with:
```
- tech_feasibility_context: One sentence on what core tech is needed, whether it's off-the-shelf or requires R&D, and key technical challenges. Wrap at most 2 key data points or facts in <strong> tags. Maximum 2 <strong> elements. HARD LIMIT: plain text content (excluding <strong></strong> tags) must be ≤ 300 characters with spaces.
```

- [ ] **Step 2: Locate `regulatory_risk_context` instruction** (around line 152)

Current text:
```
- regulatory_risk_context: One sentence on relevant regulations, licensing requirements, compliance hurdles, or data privacy concerns.
```

Replace with:
```
- regulatory_risk_context: One sentence on relevant regulations, licensing requirements, compliance hurdles, or data privacy concerns. Wrap at most 2 key data points or facts in <strong> tags. Maximum 2 <strong> elements. HARD LIMIT: plain text content (excluding <strong></strong> tags) must be ≤ 300 characters with spaces.
```

- [ ] **Step 3: Commit**

```bash
git add app/services/claude_service.rb
git commit -m "feat: add bold instructions and 300-char cap to execution context fields"
```

---

## Task 4: Prompt — switch `key_risk` to inline `<strong>`, remove `key_risk_highlight` rule

**Files:**
- Modify: `app/services/claude_service.rb` (Execution section + Critical rules section)

`key_risk` currently uses a separate `key_risk_highlight` substring field. We switch to inline `<strong>` tags and remove the "must be exact substring" critical rule.

- [ ] **Step 1: Locate `key_risk` and `key_risk_highlight` instructions** (around lines 153–154)

Current text:
```
- key_risk: The single biggest threat to this business succeeding. Must be one sentence that naturally contains a short phrase worth highlighting.
- key_risk_highlight: The exact substring (3-6 words) from key_risk that captures the core risk. This will be visually emphasized on the dashboard.
```

Replace with:
```
- key_risk: The single biggest threat to this business succeeding. One sentence. Wrap at most 2 critical phrases in <strong> tags. Maximum 2 <strong> elements.
- key_risk_highlight: A short phrase (3-6 words) from key_risk capturing the core risk. Kept for compatibility — the UI no longer uses this field directly.
```

- [ ] **Step 2: Locate and remove the Critical Rule for `key_risk_highlight`** (around line 179)

Find this line in the `## Critical rules` section:
```
- key_risk_highlight must be an exact substring of key_risk.
```

Delete that line entirely.

- [ ] **Step 3: Verify the Critical rules section no longer references `key_risk_highlight`**

Search for `key_risk_highlight` in the Critical rules section — it should not appear.

- [ ] **Step 4: Commit**

```bash
git add app/services/claude_service.rb
git commit -m "feat: switch key_risk to inline strong tags, deprecate key_risk_highlight rule"
```

---

## Task 5: View — `_market_size.html.erb`, sanitize `key_driver`

**Files:**
- Modify: `app/views/business_ideas/_market_size.html.erb:88`
- Test: `test/helpers/bold_sanitize_test.rb` (create)

- [ ] **Step 1: Write the failing test — create `test/helpers/bold_sanitize_test.rb`**

```ruby
require "test_helper"
require "action_view"

class BoldSanitizeTest < ActionView::TestCase
  include ActionView::Helpers::SanitizeHelper

  test "sanitize passes strong tags and strips other tags" do
    input = 'Growing at <strong>23% CAGR</strong> driven by <em>mobile adoption</em>'
    result = sanitize(input, tags: %w[strong])
    assert_includes result, "<strong>23% CAGR</strong>"
    assert_not_includes result, "<em>"
    assert_includes result, "mobile adoption"
  end

  test "sanitize handles plain text with no tags" do
    input = "Growing market driven by mobile adoption"
    result = sanitize(input, tags: %w[strong])
    assert_equal input, result
  end

  test "sanitize handles nil-safe fallback" do
    result = sanitize("n/a", tags: %w[strong])
    assert_equal "n/a", result
  end
end
```

- [ ] **Step 2: Run the test to verify it passes** (it tests `sanitize` behavior, not our views yet)

```bash
bin/rails test test/helpers/bold_sanitize_test.rb
```

Expected: 3 tests pass — this confirms `sanitize` works as expected before we use it in views.

- [ ] **Step 3: Update `_market_size.html.erb`**

Find line ~88:
```erb
<p class="market-size__driver-text"><%= market["key_driver"] || "n/a" %></p>
```

Replace with:
```erb
<p class="market-size__driver-text"><%= sanitize(market["key_driver"] || "n/a", tags: %w[strong]) %></p>
```

- [ ] **Step 4: Commit**

```bash
git add app/views/business_ideas/_market_size.html.erb test/helpers/bold_sanitize_test.rb
git commit -m "feat: sanitize key_driver to allow strong tags in market size partial"
```

---

## Task 6: View — `_competitors.html.erb`, sanitize `market_gap`

**Files:**
- Modify: `app/views/business_ideas/_competitors.html.erb:36`

- [ ] **Step 1: Find `market_gap` render line** (around line 36)

```erb
<p class="competitors__card-context"><%= competitors["market_gap"] || "n/a" %></p>
```

Replace with:
```erb
<p class="competitors__card-context"><%= sanitize(competitors["market_gap"] || "n/a", tags: %w[strong]) %></p>
```

- [ ] **Step 2: Commit**

```bash
git add app/views/business_ideas/_competitors.html.erb
git commit -m "feat: sanitize market_gap to allow strong tags in competitors partial"
```

---

## Task 7: View — `_business.html.erb`, sanitize `customer_profile` and `scalability`

**Files:**
- Modify: `app/views/business_ideas/_business.html.erb:35,49`

- [ ] **Step 1: Find and update `customer_profile`** (around line 35)

```erb
<p class="business-tab__card-context"><%= business["customer_profile"] || "n/a" %></p>
```

Replace with:
```erb
<p class="business-tab__card-context"><%= sanitize(business["customer_profile"] || "n/a", tags: %w[strong]) %></p>
```

- [ ] **Step 2: Find and update `scalability`** (around line 49)

```erb
<p class="business-tab__card-context"><%= business["scalability"] || "n/a" %></p>
```

Replace with:
```erb
<p class="business-tab__card-context"><%= sanitize(business["scalability"] || "n/a", tags: %w[strong]) %></p>
```

- [ ] **Step 3: Commit**

```bash
git add app/views/business_ideas/_business.html.erb
git commit -m "feat: sanitize customer_profile and scalability in business partial"
```

---

## Task 8: View — `_execution.html.erb`, fix all 3 fields

**Files:**
- Modify: `app/views/business_ideas/_execution.html.erb:29,35,50-55`

This is the most impactful view change. Two fields currently strip HTML with `.gsub`, one uses the `key_risk_highlight` mechanism.

- [ ] **Step 1: Find and fix `tech_feasibility_context`** (around line 29)

Current:
```erb
<p class="execution__card-context"><%= (execution["tech_feasibility_context"] || "n/a").gsub(/<[^>]+>/, "").truncate(320) %></p>
```

Replace with:
```erb
<p class="execution__card-context"><%= sanitize(execution["tech_feasibility_context"] || "n/a", tags: %w[strong]) %></p>
```

- [ ] **Step 2: Find and fix `regulatory_risk_context`** (around line 35)

Current:
```erb
<p class="execution__card-context"><%= (execution["regulatory_risk_context"] || "n/a").gsub(/<[^>]+>/, "").truncate(320) %></p>
```

Replace with:
```erb
<p class="execution__card-context"><%= sanitize(execution["regulatory_risk_context"] || "n/a", tags: %w[strong]) %></p>
```

- [ ] **Step 3: Find and fix `key_risk`** (around lines 50–55)

Current:
```erb
<p class="execution__risk-text">
  <% if execution["key_risk"].present? && execution["key_risk_highlight"].present? %>
    <%= execution["key_risk"].gsub(execution["key_risk_highlight"], "<strong>#{execution["key_risk_highlight"]}</strong>").html_safe %>
  <% else %>
    <%= execution["key_risk"] || "n/a" %>
  <% end %>
</p>
```

Replace with:
```erb
<p class="execution__risk-text">
  <%= sanitize(execution["key_risk"] || "n/a", tags: %w[strong]) %>
</p>
```

- [ ] **Step 4: Run the full test suite**

```bash
bin/rails test
```

Expected: all tests pass. If any test references `key_risk_highlight` rendering, update it to reflect the new sanitize approach.

- [ ] **Step 5: Commit**

```bash
git add app/views/business_ideas/_execution.html.erb
git commit -m "feat: fix execution partial — sanitize bold fields, replace key_risk_highlight mechanism"
```

---

## Task 9: Manual smoke test

No automated test can verify the AI outputs `<strong>` tags — that requires a real generation. This task is a manual verification checklist.

- [ ] **Step 1: Start the Rails server**

```bash
bin/dev
```

- [ ] **Step 2: Generate a new business idea through the full chat + research flow**

Create a new idea, answer the chat questions, wait for research to complete.

- [ ] **Step 3: Check each tab for bold rendering**

For each tab, confirm:
- [ ] Overview — Market Stage, Competitivity, Project Feasibility cards: `<strong>` text appears bold; no more than 2 per card
- [ ] Market Size — Key Market Driver: bold text visible if AI applied it
- [ ] Competitors — Market Gap: bold text visible if AI applied it
- [ ] Business — Customer Profile, Scalability: bold text visible if AI applied it
- [ ] Execution — Tech Feasibility context, Regulatory Risk context: bold text visible (previously these showed plain text due to HTML stripping)
- [ ] Execution — Key Risk: bold text via `<strong>` tags (not the old highlight mechanism)

- [ ] **Step 4: Verify bold is strategic (not excessive)**

Open browser DevTools → inspect a card's `<p>` text. Count `<strong>` elements — should be 0, 1, or 2. Never more than 2 per field.
