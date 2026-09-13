# Memory Learning: Preferences and Don'ts

Behavioral preferences and don'ts are **observed, never interviewed for**. Factual details (region, address, cards held) are fine to ask about directly during onboarding — see `onboarding.md`. This file is different: it covers things learned by watching what happens in a session, saved without turning it into a question.

## Signal strength decides when to save

Not every action is worth recording — that's how memory bloats. Use two tiers:

**Strong signal — save immediately, mid-session, don't wait for the end:**
- The user explicitly rejects a platform ("not Meesho", "I don't want to use Flipkart", "never suggest that again")
- The user explicitly states a lasting preference ("I always want to pay with my Amex", "I prefer buying electronics from Amazon")
- The user explains *why* they disliked something ("their delivery was late twice") — capture the reason, not just the rejection

**Weak signal — note it, but don't commit to the profile from a single instance:**
- The user simply picks one platform over others from a sorted list, with no comment. This is one data point, not yet a pattern.

Promote a weak signal to a saved `prefer` entry once the same platform is chosen consistently (roughly two or more times across sessions) without the user ever picking something else when it was an option. A single pick is not enough on its own — that avoids over-fitting a standing preference from one purchase that may have won for reasons specific to that item.

An `avoid` entry needs only one strong signal. Getting this wrong by being slightly too cautious (not suggesting a platform the user was mildly annoyed at once) costs far less than getting it wrong the other way (suggesting a platform the user explicitly asked to never see again).

## How to apply saved preferences

- Before building a candidate list in `platform-discovery.md`, drop any platform marked `avoid` in the profile's `platform_preferences` — do not present it, do not ask if it's still avoided.
- **Exception:** if the user explicitly names an avoided platform in a specific request ("actually, check Meesho for this one"), honor that explicit ask for this request — an explicit instruction always overrides a standing default. Consider quietly updating or removing the `avoid` entry afterward if their reaction suggests it's no longer warranted, again without asking about it directly.
- When multiple saved cards could apply and one is marked `preferred: true`, default to computing cashback against that one first, mentioning the others only if they'd clearly do better for this specific purchase.
- Platforms marked `prefer` can be weighted slightly higher when ranking otherwise-close candidates in `recommendation-rubric.md`, but never so much that a genuinely worse deal outranks a clearly better one just because of standing preference — preference breaks near-ties, it doesn't override the evidence.

## How to save without asking

When a strong signal appears, update `.claude/smart-shopper.local.md` directly (add or update the relevant `platform_preferences` entry or the `preferred` flag on a payment method) and say what was noted in one plain, factual line — not a question:

- Good: "Noted — I won't suggest Meesho again."
- Good: "Got it, I'll default to your Amex for these from now on."
- Wrong: "Would you like me to remember that you don't want Meesho suggested?"

The line confirms it was heard without turning a passive observation into an interruption.

## Session-end pass

At the end of a task (Step 7 in `SKILL.md`), do one last check for anything durable that happened but wasn't already saved in the moment — a platform picked for the second time in a row, a card that turned out to be used again. Fold it in the same way, still without asking. Continue to apply the durability test from `profile-schema.md`: never save what was searched for or bought, only the standing fact about how the user likes to shop.
