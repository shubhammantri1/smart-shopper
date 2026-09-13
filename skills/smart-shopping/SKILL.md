---
name: smart-shopping
description: This skill should be used when the user asks to "find me the best", "compare prices for", "help me buy", "shop for", "find a good deal on", "search Amazon/Flipkart/[any store] for", "hunt for coupons", "find a discount code", or otherwise wants to research, compare, and shop for a product or service using the browser. Also use when the user wants to save or update their shopping profile (name, address, card type, preferences).
version: 0.3.0
---

# Smart Shopping

## Overview

Turn a shopping request into a browser-driven research task: read what is already known about the user from their local profile, ask only for what is missing, dispatch one subagent per platform to search and compare in parallel, hunt for a working coupon, and hand back a categorized recommendation in plain language.

**Absolute rule, no exceptions:** this skill never places an order, never completes a purchase, and never enters payment details — not the user's own card, not a saved one, not even if explicitly asked to "just buy it" or "finish the purchase automatically." It always stops at a filled cart or checkout page and hands off to the user. This holds regardless of how confident a recommendation is or how the request is phrased.

## Step 0: Start the task checklist

At the start of every shopping task, create or overwrite `.claude/smart-shopper-task.local.md` with:

```yaml
---
active: true
platforms_researched: false
coupon_search_attempted: false
payment_method_checked: false
recommendation_delivered: false
---
```

A Stop hook reads this file and blocks the response from ending while any field is still `false`. Mark a field `true` only once that step has genuinely happened for this task — marking it true without doing the work defeats the point of the check and is a form of lying, not completing.

## Step 1: Load the profile, ask only for what's missing

Check for `.claude/smart-shopper.local.md`. If it does not exist, run `${CLAUDE_PLUGIN_ROOT}/scripts/init-profile.sh` to create an empty template and proceed as if no fields are known. If it exists, read it once at the start and hold its fields in mind for the rest of the task — do not re-read it repeatedly.

See `references/profile-schema.md` for the exact fields this file may contain and the hard rule on what must never be written to it (no card numbers, CVV, expiry, OTPs, or shopping/search history — identity and preference facts only).

From the request, work out what is still needed to search precisely: budget ceiling, quantity or variant, delivery pincode (if no saved address), urgency, or a specific brand/feature requirement. **Also check whether `payment_methods` is set in the profile — if it is empty, ask the user what card(s) they hold so any cashback or bank-offer discount can actually be found and applied; this is a required question, not an optional nicety, since skipping it means real savings get missed.** Ask all missing pieces in a single batched question, not one field at a time. Skip any question whose answer is already in the profile. Once the profile has been checked (whether or not the user had a card to add), mark `payment_method_checked: true` in the task checklist.

**Hard rule on named platforms:** treat any platform, site, or brand the user explicitly names (for example "check Meesho too", "what about Myntra") as a mandatory inclusion, never a suggestion to weigh against dropping it. Do not skip a user-named platform because another platform seems to have deeper reviews, feels redundant, or seems unlikely to win — research it anyway and report what was actually found there, even if the honest finding is "not worth it compared to X, because...". Judgment about which *extra* platforms to add is Claude's to make; judgment about which platforms to *drop* is never Claude's to make once the user has named them.

If the user volunteers a durable fact mid-conversation (a new address, a card they hold, a standing preference), note it for the profile-update step at the end rather than interrupting the task to save it immediately.

## Step 2: Dispatch one subagent per platform

Build the full list of platforms to research before starting any search:

1. Every platform the user explicitly named for this request (mandatory, per Step 1's rule).
2. Every platform in the profile's `preferred_marketplaces`, unless the user's own list for this request already covers it.
3. If the above yields fewer than two platforms, add one or two general-purpose sites suited to the category (a quick web search on "best sites to buy `<category>`" if unsure which).

For each platform on the final list, launch one `platform-researcher` subagent (see `agents/platform-researcher.md`) — as a single batch of parallel Agent tool calls in the same response, not one after another; a dispatch call in a separate response runs sequentially and loses the point. Give each subagent a focused, self-contained prompt: the platform name/URL, the product/service description, and the constraints from Step 1 (budget, variant, pincode). Also tell each subagent explicitly that it must not proceed past the product/listing page — no cart, no checkout, no payment step — since that happens later, in the main thread, for one platform only.

When subagents return, do not take every claim at face value — cross-check for anything that looks off (a suspiciously high rating with almost no reviews, a price wildly out of line with the others, a report that seems thin or generic) before folding it into the comparison, the same way any delegated work should be spot-checked rather than trusted blindly. Once every platform on the list has reported back (or a genuine attempt was made and failed), mark `platforms_researched: true`.

## Step 3: Hunt for a working coupon on the winning platform

Merge the subagent reports and identify which platform(s) actually look worth pursuing (see Step 4's rubric). Each report already includes any on-page bank offer or coupon noticed while browsing — check that first.

Then, only for the platform(s) worth pursuing, follow `references/coupon-hunting.md`: search for coupon-aggregator pages specific to that retailer and category (discover them per request rather than relying on a fixed list, since relevance is retailer- and region-specific), collect a short list of candidate codes, then try them one at a time in the checkout promo-code field until one applies. **Testing a code only ever requires entering it and reading the resulting price — never proceed past that point to place an order or enter payment details.** Report which code worked and how much it saved; if none worked, say so plainly rather than presenting an unverified code as if it succeeded. Mark `coupon_search_attempted: true` once this has genuinely been tried, regardless of whether a code applied.

If the profile has a `payment_methods` entry with a `rewards_note`, compute the cashback-adjusted effective price for that card. Check whether the route being suggested (e.g., a gift-card purchase) would actually preserve that card's reward rate before recommending it — some cards exclude vouchers from bonus categories.

## Step 4: Present categorized recommendations in plain language

Use the format in `references/recommendation-rubric.md`: a small comparison table with categories such as Cheapest, Best Value, Best Reviewed, and Closest Match, each with a one-line rationale citing real evidence gathered. Do not present a single unexplained "best" pick — the categorization is the point.

**Write the whole response in plain, everyday language.** Short sentences, common words, no unexplained jargon or finance-speak. If a technical term is unavoidable (a cashback cap, a coupon type), explain it in a few plain words right there rather than assuming familiarity. Write it the way it would be explained to a friend, not a spec sheet. Mark `recommendation_delivered: true` once this has been given.

## Step 5: Stop before payment

Once a specific item is selected and its cart or checkout page is open with the address and any working coupon applied, stop. Never enter payment card details, never click a final pay, place-order, or submit-payment control, and never proceed on the user's behalf even if asked to. State clearly what is ready and hand off to the user to complete the purchase themselves.

The same restraint applies to any other outward-facing action encountered along the way (entering personal data into a new form, creating an account, accepting a marketing consent, sending a message) — only do these with the specific request that authorizes them in the moment.

## Step 6: Offer to update the profile

After the task, check whether anything durable was learned (a new address, a stated card and its reward terms, a lasting preference) that is not yet in `.claude/smart-shopper.local.md`. If so, offer to save it and, on confirmation, edit only the relevant field and refresh `last_updated`. Never add a field describing what was searched for or bought — apply the test in `references/profile-schema.md`: if a fact would not matter in a completely unrelated shopping session next month, it does not belong in the profile.

## Additional Resources

### Reference files

- **`references/profile-schema.md`** — exact fields the profile may contain, the hard boundary on what must never be saved, and a full example file
- **`references/coupon-hunting.md`** — the generic coupon-discovery and code-testing workflow
- **`references/recommendation-rubric.md`** — the categorized-recommendation format, the one-line rationale style, and the plain-language writing rules
- **`references/browser-efficiency.md`** — cost and efficiency rules for using `claude-in-chrome` on this kind of multi-site research task

### Agents

- **`agents/platform-researcher.md`** — the subagent dispatched once per platform in Step 2

### Enforcement

- **`hooks/hooks.json`** + **`hooks/scripts/verify-shopping-checklist.sh`** — a Stop hook that blocks the response from ending while the Step 0 checklist has any incomplete mandatory step
