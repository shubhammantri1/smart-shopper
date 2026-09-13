# Browser Efficiency Rules

Multi-site shopping research can burn a lot of tool calls and tokens if run carelessly. Apply these rules to keep it fast and cost-friendly.

## Batch, don't sequence

Whenever two or more browser actions do not depend on each other's result (opening two different product pages, searching two different sites, reading the profile while also starting a navigation), issue them in the same tool-call batch rather than one call per turn. Sequential single calls multiply round-trip overhead for no benefit when the actions are independent.

## Prefer text extraction over vision

Use `get_page_text` or `find` to read prices, ratings, review counts, and coupon codes whenever the information is present as visible text — this is far cheaper than a screenshot-based read. Reserve screenshots and zoom for cases that genuinely need visual layout (confirming which button is which, checking a date picker's current state, verifying an image-based coupon code).

## Read the profile once

Load `.claude/smart-shopper.local.md` a single time near the start of the task and hold its contents in working memory for the rest of the session. Do not re-read it before every browser action.

## Stop when there is enough signal

Three to five comparable listings with real review data is usually enough to produce a confident categorized recommendation. Do not keep opening additional listings past the point where new information would change the recommendation — diminishing returns set in fast, and each additional page costs tokens and time without improving the answer.

## Reuse open tabs

Keep a small, purposeful set of tabs (one per site or comparison target) rather than opening a fresh tab for every navigation. Navigate an existing tab to a new URL when moving within the same research thread; only open a new tab for a genuinely separate parallel line of research.

## Avoid redundant re-navigation

If a page has already been read once and its content is stable (a product listing, a review page), do not re-navigate to it again later in the same task unless something on it needed to change (a coupon was applied, a date was updated). Reference the already-gathered information instead of re-fetching it.

## Scope the search before browsing

Before opening browser tabs, form a short, specific plan of which sites are actually relevant to this category and request. This is normally 2-4 sites (the profile's `preferred_marketplaces`, or platforms the user explicitly named), and stays that lean by default. Avoid an unscoped "check everything" sweep on your own initiative — it costs the most and adds the least per additional site checked.

**Exception:** once the user has explicitly confirmed a platform shortlist from the discovery step in `platform-discovery.md` — even a longer one, up to around ten — research all of it. That is a deliberate user choice, not scope creep, and the efficiency habits above (batching, text-over-vision, one profile read) are what keep even a longer confirmed list affordable, not shrinking the list behind the user's back.
