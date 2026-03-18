# Strategic Bold in Dashboard Cards

**Date:** 2026-03-18
**Scope:** `claude_service.rb` + 4 partials (`_market_size`, `_competitors`, `_business`, `_execution`)

---

## Problem

AI-generated body text in dashboard cards is plain text. Key data points (numbers, facts, risk phrases) are not visually distinguished. The overview tab already has partial `<strong>` tag support but lacks a max-2 rule and it's unenforced. Other tabs have no bold support at all. The execution tab actively strips HTML tags before rendering.

---

## Goal

Every body-text card field has strategic, AI-applied bolding: maximum 2 `<strong>` elements per field, used only for the most meaningful data point or phrase. Consistent approach across all 10 target fields.

---

## Affected Fields

| Tab | Field (JSON key) | Status before |
|-----|-----------------|---------------|
| Overview | `market_stage_context` | `<strong>` in prompt, no max rule, view sanitizes ✅ |
| Overview | `competitive_intensity_context` | same |
| Overview | `project_feasibility_context` | same |
| Market Size | `key_driver` | plain text, view renders raw |
| Competitors | `market_gap` | plain text, view renders raw |
| Business | `customer_profile` | plain text, view renders raw |
| Business | `scalability` | plain text, view renders raw |
| Execution | `tech_feasibility_context` | view strips all HTML with `.gsub` |
| Execution | `regulatory_risk_context` | view strips all HTML with `.gsub` |
| Execution | `key_risk` | separate `key_risk_highlight` mechanism, max 1 emphasis |

---

## Approach

**Inline `<strong>` tags in JSON strings, rendered via `sanitize`.**

The AI outputs `<strong>text</strong>` directly inside string values. Views call `sanitize(value, tags: %w[strong])` which safely allows only that tag and strips everything else.

This is already the established pattern for the overview tab. We extend it everywhere and enforce a consistent max-2 rule in the prompt.

---

## Prompt Changes (`claude_service.rb` — `RESEARCH_SYSTEM_PROMPT`)

### 1. Overview fields — add max-2 enforcement

The three existing fields already have `<strong>` instructions. Add this sentence to each:

> Maximum 2 `<strong>` elements per field — if you bold more, remove the least important ones.

Fields: `market_stage_context`, `competitive_intensity_context`, `project_feasibility_context`.

### 2a. Four new plain-text fields — add `<strong>` instruction

Add to the field-by-field instructions for each:

> Wrap at most 2 key data points, phrases, or facts in `<strong>` tags. Strategic use only — if nothing clearly warrants emphasis, use no bold. Maximum 2 `<strong>` elements.

Fields: `key_driver`, `market_gap`, `customer_profile`, `scalability`.

### 2b. Two new execution sentence fields — add `<strong>` instruction + character cap

For `tech_feasibility_context` and `regulatory_risk_context`, add the `<strong>` instruction AND a character cap matching the pattern used by overview fields:

> One sentence. Wrap at most 2 key data points or facts in `<strong>` tags. Maximum 2 `<strong>` elements. HARD LIMIT: plain text content (excluding `<strong></strong>` tags) must be ≤ 300 characters with spaces.

This cap replaces the safety role previously played by `.truncate(320)` in the view.

### 3. `key_risk` — switch mechanism

Replace the current `key_risk` / `key_risk_highlight` pair instruction with:

> `key_risk`: The single biggest threat to this business succeeding. One sentence. Wrap at most 2 critical phrases in `<strong>` tags. Maximum 2 `<strong>` elements.

Keep `key_risk_highlight` in the JSON schema with a minimal instruction so the AI still outputs it (backwards compat for existing DB records), but it will no longer be used by the view.

Also remove the Critical Rule at the bottom of the prompt that reads: `key_risk_highlight must be an exact substring of key_risk.` This constraint is no longer meaningful once the view stops using `key_risk_highlight`.

---

## View Changes

### `_market_size.html.erb`

```erb
# Before
<%= market["key_driver"] || "n/a" %>

# After
<%= sanitize(market["key_driver"] || "n/a", tags: %w[strong]) %>
```

### `_competitors.html.erb`

```erb
# Before
<%= competitors["market_gap"] || "n/a" %>

# After
<%= sanitize(competitors["market_gap"] || "n/a", tags: %w[strong]) %>
```

### `_business.html.erb`

```erb
# Before (customer_profile)
<%= business["customer_profile"] || "n/a" %>

# After
<%= sanitize(business["customer_profile"] || "n/a", tags: %w[strong]) %>

# Before (scalability)
<%= business["scalability"] || "n/a" %>

# After
<%= sanitize(business["scalability"] || "n/a", tags: %w[strong]) %>
```

### `_execution.html.erb`

```erb
# Before (tech_feasibility_context)
<%= (execution["tech_feasibility_context"] || "n/a").gsub(/<[^>]+>/, "").truncate(320) %>

# After
<%= sanitize(execution["tech_feasibility_context"] || "n/a", tags: %w[strong]) %>

# Before (regulatory_risk_context)
<%= (execution["regulatory_risk_context"] || "n/a").gsub(/<[^>]+>/, "").truncate(320) %>

# After
<%= sanitize(execution["regulatory_risk_context"] || "n/a", tags: %w[strong]) %>

# Before (key_risk — uses key_risk_highlight gsub)
<% if execution["key_risk"].present? && execution["key_risk_highlight"].present? %>
  <%= execution["key_risk"].gsub(execution["key_risk_highlight"], "<strong>#{execution["key_risk_highlight"]}</strong>").html_safe %>
<% else %>
  <%= execution["key_risk"] || "n/a" %>
<% end %>

# After
<%= sanitize(execution["key_risk"] || "n/a", tags: %w[strong]) %>
```

Note: `.truncate(320)` is dropped. The prompt already enforces "one sentence" for these fields.

---

## What Does NOT Change

- `key_risk_highlight` stays in the JSON schema (kept in prompt as a deprecated/silent field) so existing parsing code doesn't break. The view simply stops using it.
- No CSS changes needed — `<strong>` inherits font styling from parent elements, which already use Poppins 500.
- No database migration. The 6 new fields have plain text in existing records; bold applies to future generations only. The 3 overview fields may already contain `<strong>` tags from prior generations — the view already sanitizes them correctly, so no change needed.
- The `key_risk` view styling (`.execution__risk-text`) already handles inline `<strong>` gracefully since it's just a `<p>` tag.

---

## Rule Summary (for prompt and review)

- Max 2 `<strong>` elements per field
- Bold only data points, key phrases, or facts — not adjectives or filler words
- If nothing clearly warrants emphasis, use zero bold (don't force it)
- Never bold the entire sentence
- Never nest `<strong>` tags inside each other
- If the AI outputs other HTML tags in non-target fields, ERB escapes them as literal text — accepted limitation
