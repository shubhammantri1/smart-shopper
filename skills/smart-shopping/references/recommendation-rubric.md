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
