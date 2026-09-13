#!/bin/bash
# Creates .claude/smart-shopper.local.md with an empty template if it doesn't already exist.
# Safe to run repeatedly: quick-exits if the file is already present so it never overwrites saved data.
set -euo pipefail

STATE_DIR=".claude"
STATE_FILE="${STATE_DIR}/smart-shopper.local.md"

if [[ -f "$STATE_FILE" ]]; then
  exit 0
fi

mkdir -p "$STATE_DIR"

cat > "$STATE_FILE" <<'EOF'
---
region: ""
full_name: ""
phone: ""
addresses: []
payment_methods: []
preferred_marketplaces: []
preferred_coupon_sites: []
platform_preferences: []
budget_style: ""
notes: ""
last_updated: ""
---

# Shopping Profile

This file stores durable identity and preference facts only (see the smart-shopping
skill's references/profile-schema.md for the full rule). It never stores payment
credentials, card numbers, or shopping/search history. It is gitignored and stays
local to this machine.
EOF

echo "Created ${STATE_FILE}"
