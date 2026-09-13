# smart-shopper

A Claude Code plugin that turns Claude into a browser-based shopping copilot. It uses
[Claude in Chrome](https://www.anthropic.com) to search, compare, and hunt coupons across
real sites, remembers a small set of reusable profile facts locally, and always stops
before payment so you finish the purchase yourself.

## What it does

- Searches and compares products/services across the sites relevant to your request
- Pulls real reviews and recurring complaints from Reddit/forums alongside marketplace listings
- Hunts for a working coupon code by discovering and testing candidates at checkout
- Computes card-cashback-adjusted pricing if you've told it about a card's reward terms
- Presents categorized recommendations (Cheapest / Best Value / Best Reviewed / Closest Match) with the reasoning shown, not a single unexplained pick
- Remembers durable profile facts (name, address, card *type* and reward terms, standing preferences) so you're not re-asked every session
- Never remembers what you searched for or bought — only identity and preference facts
- Never enters payment details or completes a checkout — it stops and hands off to you

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
