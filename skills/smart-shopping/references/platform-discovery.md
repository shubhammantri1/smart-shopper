# Platform Discovery and Confirmation

This step exists for one specific case: the user asked for something generically ("find me a good winter jacket") without naming where to look. When the user already named specific platforms or brands, skip this entire step — that naming is the mandatory platform list (see `SKILL.md`'s hard rule) and the flow goes straight to dispatching subagents.

## Why discover instead of defaulting

Defaulting to whatever platforms come to mind first (usually the biggest one or two) misses where people who actually buy this category genuinely shop, and misses smaller or specialist platforms that might be the real answer for a specific product type. Figuring this out fresh, per request, gets a better shortlist than a fixed default ever would.

## How to discover

Search Reddit threads, community forums, and general web results for where real buyers in the user's region recommend buying this category — for example "best place to buy `<category>` reddit `<region>`", "where to buy `<category>` `<region>`", or a subreddit search relevant to the category. Read enough to identify a genuine pattern (multiple independent mentions), not a single comment.

Build a candidate list from what's actually recommended — this can be short (two or three) or long (up to around ten) depending on how fragmented the category is. For each candidate, note the one-line reason it came up (e.g., "repeatedly recommended in r/`<subreddit>` for reliability", "cheapest per several threads", "the specialist site for this category").

Before presenting the list, drop any platform marked `avoid` in the profile's `platform_preferences` (see `memory-learning.md`) — do not include it and do not ask whether it's still unwanted. If the user names an avoided platform explicitly for this specific request, that explicit ask overrides the standing avoid and it goes back in the list for this request only.

## Presenting the shortlist

Show the full candidate list to the user before doing anything else, in plain language, with the reason next to each:

```
Based on what people actually recommend, these are worth checking:
1. <Platform> — <one-line reason>
2. <Platform> — <one-line reason>
...
Which of these should I look into? (all of them is fine too)
```

Set `waiting_for_user: true` in the task checklist and end the turn here — do not dispatch any subagents yet. This is a real decision point, not a rhetorical question.

## After the user replies

Take the user's selection (which may be "all", a subset, or platforms they add that weren't on the list) as the confirmed list for subagent dispatch. Set `waiting_for_user: false` and proceed to Step 3 in `SKILL.md`. If the user's selection is large (many platforms confirmed), respect it — a user-confirmed long list is a deliberate choice, not the kind of unscoped sweep `browser-efficiency.md` warns against.
