#!/usr/bin/env python3
"""
PreToolUse hook: detects sequential (one-at-a-time) dispatch of
platform-researcher subagents and denies the call when it looks like a
previous agent was allowed to run to completion before this one was issued,
instructing that the remaining platforms be sent together instead.

How it detects this: real browser-driven research takes real time (at least
several seconds). Calls that are genuinely part of one parallel batch arrive
within the same instant of each other, before any of them have had time to
finish. A call arriving long after the first one in the batch, while some
confirmed platforms are still undispatched, is the signature of sequential
dispatch -- wait for agent 1, then call agent 2 -- rather than a real parallel
batch.

This complements the prose instruction in SKILL.md's Step 3, which a model
can otherwise drift away from under pressure; a hook running outside the
model's context can't be skipped the same way.

Fails open on any parsing error or missing state: this script only ever
denies a call when it is confident sequential dispatch happened, and allows
everything else. A bug here can slow down enforcement but can never make the
plugin unusable.
"""
import json
import re
import sys
import time

STATE_FILE = ".claude/smart-shopper-task.local.md"
THRESHOLD_MS = 8000


def read_frontmatter(path):
    with open(path, "r") as f:
        text = f.read()
    parts = text.split("---")
    if len(parts) < 3:
        return {}
    fm_text = parts[1]
    fields = {}
    for line in fm_text.splitlines():
        m = re.match(r'^([a-zA-Z_]+):\s*(.*)$', line)
        if m:
            key, val = m.group(1), m.group(2).strip()
            if val.startswith('"') and val.endswith('"'):
                val = val[1:-1]
            fields[key] = val
    return fields


def write_fields(path, updates):
    with open(path, "r") as f:
        text = f.read()
    for key, val in updates.items():
        text = re.sub(rf'(?m)^{re.escape(key)}:.*$', f'{key}: {val}', text)
    with open(path, "w") as f:
        f.write(text)


def as_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def main():
    try:
        raw = sys.stdin.read()
        data = json.loads(raw) if raw else {}
    except Exception:
        return 0

    if data.get("tool_name") not in ("Agent", "Task"):
        return 0

    tool_input = data.get("tool_input") or {}
    if tool_input.get("subagent_type") != "platform-researcher":
        return 0

    try:
        fields = read_frontmatter(STATE_FILE)
    except (FileNotFoundError, OSError):
        return 0
    except Exception:
        return 0

    if fields.get("active") != "true":
        return 0

    confirmed = as_int(fields.get("platforms_confirmed_count"))
    if confirmed <= 0:
        return 0  # dispatch round hasn't been set up yet -- nothing to check

    seen = as_int(fields.get("dispatch_seen_count"))
    first_ts = as_int(fields.get("dispatch_batch_first_ts"))
    now_ms = int(time.time() * 1000)

    if seen == 0:
        # First platform-researcher call seen for this round: record the
        # anchor and allow it. We can't tell yet whether siblings are coming
        # in the same message.
        try:
            write_fields(STATE_FILE, {
                "dispatch_seen_count": "1",
                "dispatch_batch_first_ts": str(now_ms),
            })
        except Exception:
            pass
        return 0

    elapsed = now_ms - first_ts if first_ts else 0

    if elapsed > THRESHOLD_MS and seen < confirmed:
        reason = (
            f"This platform-researcher dispatch arrived {elapsed}ms after the first "
            f"one in this batch -- long enough to indicate they were sent one at a "
            f"time instead of together in a single message. {seen} of {confirmed} "
            f"confirmed platforms have been dispatched so far. Cancel this call and "
            f"instead issue Agent calls for every remaining un-dispatched platform "
            f"together, in the same assistant message, the way the whole batch "
            f"should have gone out."
        )
        print(json.dumps({
            "hookSpecificOutput": {"permissionDecision": "deny"},
            "systemMessage": reason,
        }))
        return 0

    try:
        write_fields(STATE_FILE, {"dispatch_seen_count": str(seen + 1)})
    except Exception:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main() or 0)
