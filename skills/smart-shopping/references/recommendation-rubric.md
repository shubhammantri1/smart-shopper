# Recommendation Rubric

Present the research as one sorted, numbered list the user can act on directly — pick a number and say go — not a wall of separate categories they have to mentally merge themselves.

## Sort order

Rank candidates by overall merit, weighing price, rating and review count together, and coupon/cashback-adjusted final price rather than sticker price. There is no single formula — use judgment the way a careful human shopper would: a slightly pricier option with far better reviews often outranks the cheapest one with a thin, unreliable review base, and the reverse is true when the reviews are comparably solid across options.

## Format

A numbered list, most-recommended first, each entry tagged with the one or two reasons it's positioned there:

```
1. <Item> on <Platform> — ₹<final price after coupon/cashback>
   Best value: 4.6★ from 2,200 reviews, and the FIRST10 code brought the price down further.

2. <Item> on <Platform> — ₹<final price>
   Cheapest, but only 18 reviews so far — worth knowing before picking it for that reason alone.

3. <Item> on <Platform> — ₹<final price>
   Closest match to wanting a specific feature, though it costs more and has fewer reviews than #1.
```

Still name what each entry is best at (cheapest, best value, best reviewed, closest match to a stated preference) — the ranking gives an actionable order, and the tag explains why it's there, so trade-offs stay visible even in a single sorted list.

## Writing the rationale

Cite something concrete found during research, not a generic claim:

- Good: "3.9★ from 209 reviews, mixed but mostly praises vehicle condition — matches a nearby pickup point in the user's own area"
- Good: "Cheapest at ₹4,949 after the FIRST10 coupon, but only 18 ratings versus 2,200+ on the next option"
- Bad: "This is a great option for most users"
- Bad: "Highly rated and affordable"

## When evidence is thin

If review counts are very low (single digits) or conflicting, say so explicitly rather than treating a 5-star rating with 3 reviews as equivalent to a 4.2-star rating with 2,000 reviews. Small-sample ratings are noisy; call that out as part of the rationale, not as a footnote.

## After presenting the list

End with a direct, simple prompt for the next decision: which numbered item to go with, and the quantity if that still needs confirming. Set `waiting_for_user: true` in the task checklist and stop — do not proceed to cart preparation until the user picks one.

## Writing style: plain language, always

Write the whole recommendation — list, rationale, and any surrounding explanation — in plain, everyday words. The goal is that someone with no shopping or finance background can read it once and immediately understand the trade-offs.

- Use short sentences. Split a long one into two rather than adding a comma.
- Use common words over technical ones: "the discount only works up to ₹1,000 a month" instead of "the cashback accrual is capped at a monthly ceiling of ₹1,000."
- If a term can't be avoided (coupon, cashback cap, bank offer), explain it in a few plain words the first time it's used, right where it appears — not in a glossary at the end.
- Avoid stacking qualifiers and hedges ("potentially fairly reasonably good value") — say what was actually found, plainly.
- Numbers and comparisons should be easy to scan: round where rounding doesn't lose meaning, and put the most important fact first in each rationale rather than burying it after context.

Example:

- Plain: "Cheapest option. Costs ₹4,949 after using the FIRST10 code. Only 18 people have rated it, so it's a bit of an unknown."
- Not plain: "This represents the most cost-effective option post-discount-code-application, though the limited review corpus (n=18) introduces some uncertainty regarding aggregate reliability."
