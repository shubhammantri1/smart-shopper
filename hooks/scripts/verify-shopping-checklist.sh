#!/bin/bash
# Stop hook: deterministically blocks the turn from ending while a shopping task
# is active and mandatory steps haven't actually been completed yet. This exists
# because a prose instruction like "remember to check coupons" is something the
# model can forget under pressure; a hook runs outside the model's context and
# can't be skipped the same way.
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

MISSING=""
for field in platforms_researched coupon_search_attempted payment_method_checked recommendation_delivered; do
  VALUE=$(get_field "$field")
  if [[ "$VALUE" != "true" ]]; then
    MISSING="${MISSING}${MISSING:+, }${field}"
  fi
done

if [[ -n "$MISSING" ]]; then
  REASON="The shopping task checklist (.claude/smart-shopper-task.local.md) is not complete yet: ${MISSING}. Finish these steps before ending the response — dispatch any platform research still missing, attempt the coupon search (even if the honest result is that none applied), confirm the user's payment method or explicitly ask for it if not on file, and deliver the categorized recommendation. Reminder: never place an order or enter payment details at any point."
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
