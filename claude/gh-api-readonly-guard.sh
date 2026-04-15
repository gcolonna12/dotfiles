#!/usr/bin/env bash
# PreToolUse hook for Claude Code
#
# Auto-allows read-only `gh api` calls.
# Write operations defer to normal approval flow (user gets prompted).
# Non-`gh api` commands are unaffected.

set -euo pipefail

COMMAND=$(jq -r '.tool_input.command // empty')

# Only handle gh api commands
[[ "$COMMAND" =~ gh[[:space:]]+api[[:space:]] ]] || exit 0

# Isolate the gh api portion (before pipes or redirects)
GH_PART="${COMMAND%%|*}"
GH_PART="${GH_PART%%>*}"

# Detect write operations:
#   Explicit method flag: -X POST, --method=PATCH, etc.
#   Body flags: -f, --field, -F, --raw-field, --input (these flip default method to POST)
if [[ "$GH_PART" =~ (-X|--method)[=[:space:]]*(POST|PUT|DELETE|PATCH) ]] ||
   [[ "$GH_PART" =~ [[:space:]](-f|-F|--field|--raw-field|--input)[[:space:]=] ]]; then
  exit 0
fi

# No write indicators — auto-allow the read
echo '{"decision":"allow"}'
