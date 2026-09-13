# smart-shopper

A Claude Code plugin that turns Claude into a browser-based shopping copilot. It uses
[Claude in Chrome](https://www.anthropic.com) to research and shop across real sites,
remembers a small set of reusable profile facts and behavioral preferences locally, and
always stops before payment so you finish the purchase yourself.

## The flow

1. **Onboarding, once** — the first time it needs your region (which decides which sites
   are even relevant), it asks once, briefly. Everything else about you is optional and
   can come later.
2. **Figure out intent** — if you name a platform ("check Amazon and Meesho"), that's
   mandatory, no substitutions. If you don't name one, it researches Reddit and forums
   for where people actually buy that category, and shows you the shortlist to approve
   *before* touching a browser.
3. **Research in parallel** — one subagent per confirmed platform, dispatched together,
   not one after another.
4. **Coupons, for the top few candidates** — discovered fresh per request, tested at
   checkout, never assumed to work just because an aggregator page claims it does.
5. **One sorted, plain-language list** — ranked by price, reviews, and coupon/cashback-
   adjusted final cost, each entry tagged with why it's positioned there.
6. **You pick one** — only then does it add it to cart, select your address, apply the
   working coupon, and select (never enter) a saved payment method, and stop right there.

Two hard rules run through every step: it **never places an order or enters payment
details**, and it **never re-asks something it should already know** — deterministically
enforced by a Stop hook, not just a prompt reminder (see "How it's built" below).

## Install

```
/plugin marketplace add <your-github-username>/smart-shopper
/plugin install smart-shopper@smart-shopper-marketplace
```

Or run it locally without publishing:

```
claude --plugin-dir /path/to/smart-shopper
```

## Usage

Just ask:

> "Find me a good pair of running shoes under ₹3000"

> /shop a mechanical keyboard under $80, check Amazon and also Meesho

The skill asks for anything it still needs, confirms which platforms to check when the
request is generic, then does the research.

## Your data — and how memory actually works

`.claude/smart-shopper.local.md` is created the first time it's needed, in whatever
project directory you're working from. It is:

- **Local only** — never committed to git (see `.gitignore`)
- **Small by design** — identity, region, standing preferences, and don'ts only
- **Never** used to store card numbers, CVVs, OTPs, passwords, or what you searched for
  or bought

Two different things get saved, two different ways:

- **Facts** (region, address, a card you mention and its reward terms) are asked about
  directly, once, during onboarding — and never asked again once saved.
- **Preferences and don'ts** (a platform you clearly dislike, a card you keep choosing)
  are learned by watching what happens, not by being interviewed for. Say once "don't
  ever suggest Meesho" and it's saved immediately and excluded from every future
  shortlist — no confirmation dialog, just a one-line "noted" so you know it landed.

See `skills/smart-shopping/references/profile-schema.md` for the exact schema and
`references/memory-learning.md` for exactly how preferences get learned and applied.

## How it's built

- `skills/smart-shopping/` — the orchestrating skill and its step-by-step references
  (onboarding, platform discovery, coupon hunting, the recommendation format, cart
  preparation, and memory learning)
- `agents/platform-researcher.md` — the subagent launched once per confirmed platform;
  scoped to research only, never past a product/listing page
- `hooks/` — a Stop hook that deterministically blocks a shopping response from ending
  until the task's mandatory steps (platform research, coupon search, payment-method
  check, delivering the recommendation) have actually happened, unless the flow is
  legitimately paused waiting on the user. This exists because "please remember to
  check coupons" is an instruction a model can forget under pressure — a hook running
  outside the model's context can't be skipped the same way.

## License

MIT — see `LICENSE`.
