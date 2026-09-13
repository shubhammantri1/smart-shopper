# Profile Schema

The profile lives at `.claude/smart-shopper.local.md` in the project directory the skill is run from. It follows the standard Claude Code plugin-settings pattern: YAML frontmatter for structured fields, markdown body for freeform notes. It is user-local and must never be committed to version control (see the plugin's `.gitignore`).

## The durability test

Before writing anything to this file, apply one test: **would this fact matter in a completely unrelated shopping session next month?**

- "User is shopping from India" — yes, durable, save it. This is the single most useful fact for filtering out irrelevant regional sites.
- "User's delivery pincode is 560037" — yes, durable, save it.
- "User is looking for a washing machine pressure pump" — no, that's this session's task, not a durable fact. Do not save it.
- "User holds an HDFC Millennia card with 5% capped cashback on Amazon" — yes, durable, save it.
- "User compared three pumps and picked the V-Guard one" — no, that's shopping history. Do not save it.

## Fields that may be saved

```yaml
---
region: ""            # e.g. "India", "United States" — decides which regional storefronts and coupon sources are even relevant
full_name: ""
phone: ""
addresses:
  - label: ""          # e.g. "Home", "Office"
    line1: ""
    city: ""
    state: ""
    pincode: ""
payment_methods:
  - label: ""           # e.g. "HDFC Millennia"
    network: ""          # e.g. "Visa", "Amazon Pay ICICI"
    type: ""             # "credit" | "debit"
    rewards_note: ""     # plain description of the cashback/reward terms, not the card itself
    preferred: false     # set true once there's a clear signal this is the one to default to
preferred_marketplaces: []   # e.g. ["amazon", "flipkart"] — only what the user actually uses
preferred_coupon_sites: []   # optional, only if the user names specific ones
platform_preferences:
  - platform: ""
    sentiment: ""        # "prefer" | "avoid"
    reason: ""           # short, concrete — what happened that caused this
budget_style: ""        # "cheapest" | "balanced" | "premium"
notes: ""                # short freeform durable preferences
last_updated: ""
---
```

Every field is optional. Only write a field once it is actually known — do not pre-fill placeholders or guess values.

## Fields that must never be saved

- Card numbers, CVV, expiry dates, PINs, OTPs, or any other payment credential. `payment_methods` describes the *kind* of card and its reward terms in plain language, never the card itself.
- Passwords or account credentials of any kind.
- Specific product searches, product names, or categories browsed.
- Purchase history or order numbers.
- Browsing history or session-specific context.

If asked to save any of the above, decline and explain that this profile only stores identity and standing preferences, never payment credentials or shopping history — the same way the browser-automation policy that governs this skill never handles payment details directly.

## Example file

```markdown
---
region: India
full_name: Shubham Mantri
phone: "8949413639"
addresses:
  - label: Home
    line1: Villa 162, Ferns Habitat, 2nd Floor
    city: Bengaluru
    state: Karnataka
    pincode: "560037"
payment_methods:
  - label: HDFC Millennia
    network: Visa
    type: credit
    rewards_note: 5% cashback on Amazon/Flipkart, capped at ₹1000/month combined across categories
    preferred: false
  - label: Amazon Pay ICICI
    network: Amazon Pay ICICI
    type: credit
    rewards_note: 5% cashback on Amazon for Prime members, uncapped, credited as Amazon Pay balance
    preferred: true
preferred_marketplaces: [amazon, flipkart]
preferred_coupon_sites: []
platform_preferences:
  - platform: Meesho
    sentiment: avoid
    reason: Said a seller was unreliable there and asked not to be shown it again
budget_style: balanced
notes: Prefers branded over generic for appliances; renting, avoids anything needing plumbing/permanent installation.
last_updated: "2026-09-13"
---

# Notes

No shopping history is stored here — only identity and standing preferences.
```

## Reading and writing

Read the file directly with the Read tool at the start of a shopping task; there is no need for a shell parser given the file is small and the model reads YAML natively. When updating, edit only the specific field that changed and refresh `last_updated` — leave the rest of the file untouched.
