# Recommendation Rubric

Present shopping research as a small set of categorized picks, never a single unexplained "best" answer. The categorization is what lets the user weigh trade-offs themselves instead of trusting a black-box ranking.

## Standard categories

Use whichever of these apply to the specific research — not every category is relevant to every request:

- **Cheapest** — lowest total price after any applied coupon, before considering quality trade-offs.
- **Best Value** — the strongest ratio of price to quality/features/reviews; usually not the cheapest or the most expensive option.
- **Best Reviewed / Most Reliable** — highest genuine review signal (rating combined with review count, and an absence of recurring serious complaints), even if pricier.
- **Closest Match** — best fit to a specific stated preference (a brand, a feature, a size/variant, a delivery timeline) even if it loses on price or aggregate rating.

Add a category only when the evidence actually supports it — do not force four categories onto two comparable options.

## Format

Present a comparison table with columns for price, rating/review count, and a one-line rationale, followed by a short prose recommendation. For example:

| Option | Price | Rating | Why |
|---|---|---|---|
| Option A | ₹X | 4.2★ (2,200) | Cheapest after coupon; largest review base of the three |
| Option B | ₹Y | 4.6★ (300) | Best reviewed; recurring praise for durability, no complaint pattern found |
| Option C | ₹Z | 4.0★ (50) | Closest match — only one with the specific feature the user asked for |

## Writing the rationale

Each rationale must cite something concrete found during research, not a generic claim:

- Good: "3.9★ from 209 reviews, mixed but mostly praises vehicle condition — matches a nearby pickup point in the user's own area"
- Good: "Cheapest at ₹4,949 after the FIRST10 coupon, but only 18 ratings versus 2,200+ on the next option"
- Bad: "This is a great option for most users"
- Bad: "Highly rated and affordable"

Where relevant, fold in the coupon-adjusted price from `coupon-hunting.md` and the card-cashback-adjusted effective price from the user's profile, so the comparison reflects what the user would actually pay, not the sticker price.

## When evidence is thin

If review counts are very low (single digits) or conflicting, say so explicitly rather than treating a 5-star rating with 3 reviews as equivalent to a 4.2-star rating with 2,000 reviews. Small-sample ratings are noisy; call that out as part of the rationale, not as a footnote.

## Writing style: plain language, always

Write the whole recommendation — table, rationale, and any surrounding explanation — in plain, everyday words. The goal is that someone with no shopping or finance background can read it once and immediately understand the trade-offs.

- Use short sentences. Split a long one into two rather than adding a comma.
- Use common words over technical ones: "the discount only works up to ₹1,000 a month" instead of "the cashback accrual is capped at a monthly ceiling of ₹1,000."
- If a term can't be avoided (coupon, cashback cap, bank offer), explain it in a few plain words the first time it's used, right where it appears — not in a glossary at the end.
- Avoid stacking qualifiers and hedges ("potentially fairly reasonably good value") — say what was actually found, plainly.
- Numbers and comparisons should be easy to scan: round where rounding doesn't lose meaning, and put the most important fact first in each rationale rather than burying it after context.

Example:

- Plain: "Cheapest option. Costs ₹4,949 after using the FIRST10 code. Only 18 people have rated it, so it's a bit of an unknown."
- Not plain: "This represents the most cost-effective option post-discount-code-application, though the limited review corpus (n=18) introduces some uncertainty regarding aggregate reliability."
