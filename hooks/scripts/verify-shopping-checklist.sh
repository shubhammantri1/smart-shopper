#!/bin/bash
# Stop hook: deterministically blocks the turn from ending while a shopping task
# is active, the flow is NOT legitimately waiting on the user, and a mandatory
# step hasn't actually been completed yet. This exists because a prose
# instruction like "remember to check coupons" is something the model can
# forget under pressure; a hook runs outside the model's context and can't be
# skipped the same way.
#
# waiting_for_user: true is always allowed to stop -- several points in the
# flow (platform shortlist confirmation, the final pick, quantity) correctly
# pause for a user reply, and that's not a skipped step.
#
# Quick-exits (no-op) whenever there is no active shopping task, so this never
# interferes with normal, non-shopping conversation.
set -euo pipefail

STATE_FILE=".claude/smart-shopper-task.local.md"

if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")

get_field() {
  echo "$FRONTMATTER" | grep "^$1:" | sed "s/^$1: *//" | sed 's/^"\(.*\)"$/\1/'
}

ACTIVE=$(get_field active)
if [[ "$ACTIVE" != "true" ]]; then
  exit 0
fi

WAITING=$(get_field waiting_for_user)
if [[ "$WAITING" == "true" ]]; then
  exit 0
fi

MISSING=""
for field in region_known payment_method_checked platforms_researched coupon_search_attempted recommendation_delivered; do
  VALUE=$(get_field "$field")
  if [[ "$VALUE" != "true" ]]; then
    MISSING="${MISSING}${MISSING:+, }${field}"
  fi
done

if [[ -n "$MISSING" ]]; then
  REASON="The shopping task checklist (.claude/smart-shopper-task.local.md) is not complete and waiting_for_user is false, so this isn't a legitimate pause: ${MISSING}. Either finish these steps before ending the response, or if the next move genuinely requires the user's input (a platform shortlist to confirm, an item to pick, a missing detail), set waiting_for_user: true in the checklist and ask for it explicitly. Reminder: never place an order or enter payment details at any point."
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg reason "$REASON" '{"decision":"block","reason":$reason}'
  else
    printf '{"decision":"block","reason":%s}' "$(printf '%s' "$REASON" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
  fi
  exit 0
fi

# All mandatory steps done — deactivate so later, unrelated turns in this
# project are never blocked by a completed task's leftover state.
TMP="${STATE_FILE}.tmp.$$"
sed 's/^active: .*/active: false/' "$STATE_FILE" > "$TMP" && mv "$TMP" "$STATE_FILE"
exit 0
