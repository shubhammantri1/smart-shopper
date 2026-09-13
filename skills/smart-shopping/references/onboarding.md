# Onboarding and Profile Check

## Why region comes first

Which sites are even worth searching depends entirely on where the user is. Suggesting amazon.com to someone in India, or an India-only site to someone in the US, wastes the whole research pass. Region is the one fact that must be known before any platform discovery or searching happens.

## First-time flow

Treat the user as first-time whenever `.claude/smart-shopper.local.md` doesn't exist, or exists but has no `region` set. Run `${CLAUDE_PLUGIN_ROOT}/scripts/init-profile.sh` first if the file is missing.

Ask a single short, batched question covering:

- **Region/country** — required. Explain briefly why: it decides which sites and coupon sources are even usable.
- **Name and a default delivery address/pincode** — optional, only if they're comfortable sharing now; can be added later.
- **Any card(s) they hold and roughly what the rewards are** — optional now, but mention it saves a step later since it's how cashback gets found.
- **Budget style** (cheapest / balanced / premium) and any standing brand preference — optional.

Make clear every field except region can be skipped for now and added later. Do not turn this into a long form — one message, one batched ask, move on.

Once region is known (freshly given or already on file), mark `region_known: true` in the task checklist and proceed.

## Returning-user flow

Read `.claude/smart-shopper.local.md` once at the start of the task. Do not re-ask anything already present. Only ask for what this specific request still needs beyond the profile: a budget ceiling for this item, a variant/size, quantity if relevant, or a payment method if none is saved yet (see Step 1 in `SKILL.md` — this is a required check, not optional, since skipping it means missed cashback).

If the request implies a different region than the saved one (for example, shipping to a different country temporarily), confirm which region applies for this specific purchase rather than silently assuming the saved one.

## Region-gating rule

Never suggest or search a platform whose regional storefront doesn't serve the user's region, unless the user explicitly says they're ordering across borders (e.g., importing something, shipping to a relative abroad). Use the region-appropriate storefront domain and locally-relevant coupon sources by default.
