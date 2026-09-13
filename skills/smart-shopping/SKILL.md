---
name: smart-shopping
description: This skill should be used when the user asks to "find me the best", "compare prices for", "help me buy", "shop for", "find a good deal on", "search Amazon/Flipkart/[any store] for", "hunt for coupons", "find a discount code", or otherwise wants to research, compare, and shop for a product or service using the browser. Also use when the user wants to save or update their shopping profile (name, address, card type, preferences).
version: 0.1.0
---

# Smart Shopping

## Overview

Turn a shopping request into a browser-driven research task using `claude-in-chrome`: read what is already known about the user from their local profile, ask only for what is missing, search and compare across sites, pull real reviews, hunt for a working coupon, and hand back a categorized recommendation. Never complete a payment — always stop at a filled cart or checkout page and let the user finish.

## Step 1: Load the profile, ask only for what's missing

Check for `.claude/smart-shopper.local.md` in the current project directory.

- If it does not exist, run `${CLAUDE_PLUGIN_ROOT}/scripts/init-profile.sh` to create an empty template, then proceed as if no fields are known.
- If it exists, read it once at the start of the task (not repeatedly) and hold the fields in mind for the rest of the session.

See `references/profile-schema.md` for the exact fields this file may contain and the hard rule on what must never be written to it (no card numbers, CVV, expiry, OTPs, or shopping/search history — identity and preference facts only).

From the user's request, work out what is still needed to search precisely: budget ceiling, quantity or variant, delivery pincode (if no saved address), urgency, or a specific brand/feature requirement. Ask for missing pieces in a single batched question, not one field at a time. Skip any question whose answer is already in the profile — restating a known fact back to the user to confirm is fine; re-asking it as an open question is not.

If the user volunteers a durable fact mid-conversation (a new address, a card they hold, a standing preference), note it for the profile-update step at the end. Do not interrupt the shopping task to save it immediately unless the user asks.

## Step 2: Search and compare

Use `claude-in-chrome` to search the sites relevant to the request — the user's `preferred_marketplaces` from the profile if set, otherwise general web search to identify the right sites for the category first. Batch independent browser actions into single tool-call messages rather than one action per turn. See `references/browser-efficiency.md` for the specific rules that keep this fast and cheap (prefer `get_page_text`/`find` over screenshots when text is enough, read the profile once, stop once there is enough signal to compare rather than exhaustively crawling every possible listing).

Alongside marketplace listings, pull real user experience from review sources — Reddit threads, community forums, or review aggregators for the category — the same way a careful human shopper would cross-check a listing's star rating against what actual buyers say. Note recurring complaints (not just isolated one-off reviews) and anything a listing's marketing copy would not mention.

## Step 3: Hunt for a working coupon

Follow `references/coupon-hunting.md`. In short: search for coupon-aggregator pages specific to the retailer and category (do not rely on a fixed list of coupon sites — discover them per request, since sites relevant to one region or retailer will not apply to another), collect a short list of candidate codes, then try them one at a time in the checkout promo-code field until one applies. Report which code worked and how much it saved; if none worked, say so plainly rather than presenting an unverified code as if it succeeded.

If the profile has a `payment_methods` entry with a `rewards_note`, compute the cashback-adjusted effective price for that card the way a savings-conscious shopper would (rate, cap, whether the category is covered) and mention it alongside the coupon savings — but never suggest routing a purchase through a gift-card or voucher intermediary without checking whether that actually preserves the cashback rate for that specific card, since some cards exclude vouchers.

## Step 4: Present categorized recommendations

Use the format in `references/recommendation-rubric.md`: a small comparison table with categories such as Cheapest, Best Value, Best Reviewed, and Closest Match to the user's stated preference, each with a one-line rationale that cites the actual evidence gathered (price, rating and review count, a specific recurring complaint or praise, coupon-adjusted final price). Do not present a single "best" pick without the comparison — the categorization is the point, so the user can weigh trade-offs themselves.

## Step 5: Stop before payment

Once a specific item is selected and its cart or checkout page is open with the address and any working coupon applied, stop. Never enter payment card details, never click a final pay, place-order, or submit-payment control. State clearly what is ready and hand off to the user to complete the purchase themselves. This is a hard rule, not a preference — it holds regardless of how confident the recommendation is or how explicitly the user asks for the purchase to be finished automatically.

The same restraint applies to entering personal data into any other form (shipping address fields, account creation, sign-in) and to any other outward-facing action (sending a message, posting somewhere, accepting a marketing consent checkbox): do these only with the specific request that authorizes them in the moment, the same way any browser-automation task should.

## Step 6: Offer to update the profile

After the task, check whether anything durable was learned during the conversation (a new address, a stated card and its reward terms, a lasting brand or budget preference) that is not yet in `.claude/smart-shopper.local.md`. If so, offer to save it and, on confirmation, edit the file directly — add or update the relevant field, update `last_updated`, and leave everything else untouched. Never add a field describing what was searched for or bought; the profile is for identity and standing preferences only, never shopping history. Apply the test in `references/profile-schema.md`: if a fact would not matter in a completely unrelated shopping session next month, it does not belong in the profile.

## Additional Resources

### Reference files

- **`references/profile-schema.md`** — exact fields the profile may contain, the hard boundary on what must never be saved, and a full example file
- **`references/coupon-hunting.md`** — the generic coupon-discovery and code-testing workflow
- **`references/recommendation-rubric.md`** — the categorized-recommendation format and how to write the one-line rationales
- **`references/browser-efficiency.md`** — cost and efficiency rules for using `claude-in-chrome` on this kind of multi-site research task
