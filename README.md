# smart-shopper

A Claude Code plugin that turns Claude into a browser-based shopping copilot. It uses
[Claude in Chrome](https://www.anthropic.com) to search, compare, and hunt coupons across
real sites, remembers a small set of reusable profile facts locally, and always stops
before payment so you finish the purchase yourself.

## What it does

- Dispatches one subagent per platform (Amazon, Flipkart, Meesho, whatever you name or have saved as a preference) to search and compare **in parallel**, instead of researching sites one at a time
- Treats any platform you explicitly name as mandatory — it won't quietly drop one because another site "seemed to have better reviews"
- Pulls real reviews and recurring complaints from Reddit/forums alongside marketplace listings
- Hunts for a working coupon code by discovering and testing candidates at checkout
- Asks what card(s) you hold if it doesn't already know, so cashback/bank-offer discounts don't get missed, and computes the card-adjusted effective price
- Presents categorized recommendations (Cheapest / Best Value / Best Reviewed / Closest Match) with the reasoning shown, not a single unexplained pick
- Writes recommendations in plain, everyday language — no unexplained jargon
- Remembers durable profile facts (name, address, card *type* and reward terms, standing preferences) so you're not re-asked every session
- Never remembers what you searched for or bought — only identity and preference facts
- **Never places an order or enters payment details, under any circumstance** — a Stop hook (`hooks/`) deterministically blocks the response from ending until the mandatory research/coupon/card-check steps for the task actually happened, rather than relying on the model remembering to do them

## How it's built

- `skills/smart-shopping/` — the orchestrating skill: loads your profile, works out what's missing, dispatches subagents, merges their findings, hunts coupons, writes the recommendation
- `agents/platform-researcher.md` — the subagent launched once per platform; scoped to research only, never past a product/listing page
- `hooks/` — a Stop hook that enforces the task checklist (platforms researched, coupon search attempted, payment method checked, recommendation delivered) before letting a shopping response finish

## Install

```
/plugin marketplace add <your-github-username>/smart-shopper
/plugin install smart-shopper@smart-shopper-marketplace
```

Or run it locally without publishing, from this folder:

```
claude --plugin-dir /path/to/smart-shopper
```

## Usage

Just ask, from any project where the plugin is enabled:

> "Find me a good pair of running shoes under ₹3000"

> /shop a mechanical keyboard under $80 with hot-swappable switches

The skill will ask for anything it still needs to narrow the search, then do the research
in your browser via Claude in Chrome.

## Your data

The first time it needs to remember something, the skill creates
`.claude/smart-shopper.local.md` in whatever project directory you're working from. This
file is:

- **Local only** — never committed to git (see `.gitignore`)
- **Small by design** — identity and standing preferences only (name, address, card type
  and reward terms, preferred sites, budget style)
- **Never** used to store card numbers, CVVs, OTPs, passwords, or anything you searched
  for or bought

See `skills/smart-shopping/references/profile-schema.md` for the exact schema and the
hard rule on what is never saved.

## License

MIT — see `LICENSE`.
