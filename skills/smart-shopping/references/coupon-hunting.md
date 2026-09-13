# Coupon Hunting Workflow

Discover coupons per request rather than relying on a fixed list of coupon sites. A hardcoded list goes stale fast and does not generalize across regions or retailers — search for it fresh each time instead.

## Step 1: Discover candidate coupon sources

Run a web search for the specific retailer and category, for example:
- `"<retailer>" coupon code <month> <year>`
- `"<retailer>" promo code site:<known-aggregator-pattern>` only if the user's profile lists `preferred_coupon_sites`
- `<category> discount code <retailer>`

Open the two or three most relevant, most recently updated results — prefer pages that show a specific date or "verified" marker over generic evergreen listing pages, since coupon codes expire constantly and stale aggregator pages are common.

## Step 2: Also check the retailer's own page

Many sites surface an active coupon or bank-offer directly on the product or checkout page (a "Bank Offer" or "Coupon" section, or a small clippable coupon badge). Check this before trusting a third-party aggregator, since retailer-listed offers are more likely to still be valid and to actually apply cleanly.

## Step 3: Collect a short candidate list

Note 2-4 candidate codes with their claimed discount, rather than one. Aggregator pages frequently list codes that no longer work; having a short list to try increases the odds of finding one that does.

## Step 4: Try each candidate at checkout

At the checkout or cart promo-code field, enter each candidate in turn and check for a success or failure message before moving to the next. Stop as soon as one applies. Report:
- Which code applied and the actual discount amount observed at checkout (not the claimed discount from the aggregator page, which may differ).
- If none applied, say so plainly rather than presenting an untested code as a working discount.

## Step 5: Cross-check card-based cashback separately

Coupon codes and card cashback are usually independent and stack. After a coupon is applied (or confirmed unavailable), separately check the checkout page for card-specific bank offers or cashback callouts, and cross-reference against the profile's `payment_methods.rewards_note` if present. Note explicitly if a specific route (e.g., buying a gift card first) would reduce or void a card's reward rate — many cards exclude voucher/gift-card purchases from bonus cashback categories, so check this rather than assuming a workaround increases savings.

## Efficiency notes

- Do not open more than 3-4 candidate coupon pages; diminishing returns set in fast and most aggregator sites duplicate the same handful of codes.
- Prefer `get_page_text` over screenshots when scanning a coupon-listing page — the codes are almost always in visible text, not images.
- If a retailer explicitly shows a "Coupons" tab or clip-to-apply button on its own page, that single check is often sufficient and faster than an external aggregator search.
