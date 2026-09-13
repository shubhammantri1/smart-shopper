---
name: smart-shopping
description: This skill should be used when the user asks to "find me the best", "compare prices for", "help me buy", "shop for", "find a good deal on", "search Amazon/Flipkart/[any store] for", "hunt for coupons", "find a discount code", or otherwise wants to research, compare, and shop for a product or service using the browser. Also use when the user wants to save or update their shopping profile (name, region, address, card type, preferences).
version: 0.5.0
---

# Smart Shopping

## Overview

The full pipeline: know the user's region and preferences (asking once, remembering after), work out what they actually want to buy, figure out *where* to look — either platforms they named, or platforms real buyers recommend when the request is generic — get the user's sign-off on that shortlist, research it in parallel with one subagent per platform, hunt coupons across the strongest candidates, present one sorted list in plain language, and only after the user picks one item, prepare its cart end to end and stop right before payment.

**Absolute rule, no exceptions:** this skill never places an order, never completes a purchase, and never enters payment details — not the user's own card, not a saved one, not even if explicitly asked to "just buy it" or "finish it automatically." It always stops at a filled cart or checkout page and hands off to the user. This holds regardless of how confident a recommendation is or how the request is phrased.

## Step 0: Start the task checklist

At the start of every shopping task, create or overwrite `.claude/smart-shopper-task.local.md`:

```yaml
---
active: true
waiting_for_user: false
region_known: false
payment_method_checked: false
platforms_researched: false
coupon_search_attempted: false
recommendation_delivered: false
---
```

A Stop hook reads this file. It always allows the turn to end while `waiting_for_user: true` (there are several legitimate points below where the right move is to ask the user something and wait). Whenever `waiting_for_user` is false, it blocks the turn from ending until the other fields are true — mark a field true only once that step has genuinely happened; marking it true without doing the work defeats the point of the check.

Set `waiting_for_user: true` immediately before ending a turn to ask the user anything, and set it back to `false` once their reply is being acted on.

## Step 1: Onboarding and profile check

See `references/onboarding.md`. In short: read `.claude/smart-shopper.local.md` once (run `${CLAUDE_PLUGIN_ROOT}/scripts/init-profile.sh` first if it doesn't exist). If `region` isn't set yet, this is effectively a first-time user — ask a single batched question covering region (required — it decides which sites are even relevant), and optionally name, address, cards held, and budget style. If the profile is already filled in, skip every field already known and only ask what this specific request still needs: a budget ceiling, a variant, quantity if relevant, or a payment method if `payment_methods` is still empty (required, since skipping it means missed cashback). Mark `region_known` and `payment_method_checked` true once each has actually been confirmed either way.

**Hard rule on named platforms:** treat any platform, site, or brand the user explicitly names (for example "check Meesho too") as a mandatory inclusion, never a suggestion to weigh against dropping it. Never skip a user-named platform because another seems to have deeper reviews or feels redundant — research it anyway and report what was actually found, even if the honest finding is "not worth it, because...". When platforms are named this way, Step 2's discovery process is skipped entirely — go straight to Step 3 with the named platforms. An explicit ask for a specific request always overrides a standing `avoid` entry from `platform_preferences` (see below) for that one request.

**Preferences and don'ts are learned by watching, not by asking.** If the profile already has `platform_preferences` or a `preferred` payment method, use them silently — exclude anything marked `avoid` from consideration, lean toward what's marked `prefer` when candidates are otherwise close, and default cashback math to the `preferred` card. See `references/memory-learning.md` for exactly how these get learned and applied; do not interview the user for them the way region or address get asked about.

## Step 2: Figure out where to look, if the request is generic

Skipped whenever the user already named specific platforms (Step 1's hard rule applies instead). Otherwise, see `references/platform-discovery.md`: research Reddit, forums, and general web results for where real buyers in the user's region actually recommend this category, build a candidate shortlist (however long that turns out to be — a couple of platforms or up to around ten), and present it to the user with a one-line reason for each before doing anything else. Set `waiting_for_user: true` and stop there — this is a real decision point, not rhetorical. Once the user replies, their selection becomes the confirmed platform list.

## Step 3: Dispatch one subagent per confirmed platform

For each platform on the confirmed list (from Step 1's named platforms or Step 2's user-selected shortlist), launch one `platform-researcher` subagent — as a single batch of parallel Agent tool calls in the same response, not one after another. Give each a focused, self-contained prompt: the platform, the product/service description, and the constraints from Step 1. Tell each subagent explicitly not to go past the product/listing page. The agent's own frontmatter already pins it to a fast, inexpensive model at moderate effort (`agents/platform-researcher.md`) — this is mechanical browse-and-extract work, not deep reasoning, so dispatch it as defined rather than at the orchestrator's own model/effort level.

When subagents return, spot-check anything that looks off (a suspiciously high rating with almost no reviews, a price wildly out of line with the others) before folding it into the comparison, rather than trusting every report at face value. Once every confirmed platform has reported back, mark `platforms_researched: true`.

## Step 4: Hunt coupons across the top candidates

Follow `references/coupon-hunting.md`: for the strongest 3-5 candidates across the confirmed platforms (not just one), discover and test coupon codes so the recommendation list can show real final prices. If a `payment_methods` entry has a `rewards_note`, compute the cashback-adjusted effective price too, checking whether the suggested route (e.g., a gift card) would actually preserve that card's reward rate. Mark `coupon_search_attempted: true` once genuinely attempted, regardless of outcome.

## Step 5: Present one sorted list, in plain language

Follow `references/recommendation-rubric.md`: a single numbered list, most-recommended first, each entry tagged with why it's positioned there (cheapest, best value, best reviewed, closest match) and its coupon/cashback-adjusted final price. Write it in plain, everyday language throughout — short sentences, no unexplained jargon. Mark `recommendation_delivered: true`. End by asking which numbered item to go with (and quantity, if not already clear and it applies). Set `waiting_for_user: true` and stop — do not touch any cart until the user picks one.

## Step 6: Prepare the cart for the chosen item, then stop

Once the user picks a specific item, follow `references/cart-preparation.md`: confirm quantity if still needed, add the item to cart, select the delivery address, apply the coupon already confirmed working, and select — never enter — a saved payment method if the platform offers one to choose from. Stop at the fully prepared checkout page. Never click a final pay, place-order, or submit-payment control, and never enter card details, CVV, expiry, or an OTP under any circumstance, even if asked to finish the purchase.

The same restraint applies to any other outward-facing action along the way (a new account, a marketing consent, a message) — only do these with the specific request that authorizes them in the moment.

## Step 7: Update memory from this session

Factual details (region, address, a newly mentioned card and its reward terms) can be confirmed with the user directly, the same way onboarding does, then saved.

Behavioral preferences and don'ts are different: save them directly, without asking. Per `references/memory-learning.md`, a strong signal — an explicit rejection of a platform, an explicit statement of a lasting preference — gets captured the moment it happens in the conversation, not held until the end. A weak signal (one unremarked platform pick) gets promoted to a saved preference only once it repeats. Either way, state what was noted in one plain factual line ("Noted — I won't suggest Meesho again") rather than asking whether to remember it.

At the end of the task, do one last pass for anything durable that happened but wasn't already saved, and fold it in the same way. Never add a field describing what was searched for or bought — apply the test in `references/profile-schema.md`: if a fact wouldn't matter in a completely unrelated shopping session next month, it doesn't belong in the profile.

## Additional Resources

### Reference files

- **`references/onboarding.md`** — first-time vs. returning-user profile flow, and why region comes first
- **`references/memory-learning.md`** — how preferences and don'ts get learned from behavior and applied silently, without interviewing for them
- **`references/platform-discovery.md`** — the Reddit/forum-based discovery workflow and shortlist confirmation
- **`references/coupon-hunting.md`** — the coupon-discovery and code-testing workflow across top candidates
- **`references/recommendation-rubric.md`** — the sorted-list format, rationale style, and plain-language rules
- **`references/cart-preparation.md`** — quantity, address, coupon, and payment-method selection up to the final stop-before-payment boundary
- **`references/browser-efficiency.md`** — cost and efficiency rules for `claude-in-chrome` on multi-site research

### Agents

- **`agents/platform-researcher.md`** — the subagent dispatched once per confirmed platform in Step 3

### Enforcement

- **`hooks/hooks.json`** + **`hooks/scripts/verify-shopping-checklist.sh`** — a Stop hook that blocks the response from ending while the Step 0 checklist has an incomplete mandatory step and the flow isn't legitimately waiting on the user
