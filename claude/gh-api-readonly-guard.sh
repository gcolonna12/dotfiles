#!/usr/bin/env bash
# PreToolUse hook for Claude Code
#
# Auto-allows read-only `gh api` calls.
# Write operations defer to normal approval flow (user gets prompted).
# Non-`gh api` commands are unaffected.

set -euo pipefail

# Read the full hook payload, then extract the command. A jq failure (malformed
# payload) must not abort the hook — fall back to an empty command and defer.
INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

# Only handle gh api commands; anything else defers to the normal approval flow.
[[ "$COMMAND" =~ gh[[:space:]]+api[[:space:]] ]] || exit 0

# Isolate the gh api portion (before pipes or redirects)
GH_PART="${COMMAND%%|*}"
GH_PART="${GH_PART%%>*}"

# Detect write operations:
#   Explicit method flag: -X POST, --method=PATCH, etc.
#   Body flags: -f, --field, -F, --raw-field, --input (these flip default method to POST)
# Write ops defer to the normal approval flow (no output, plain exit).
if [[ "$GH_PART" =~ (-X|--method)[=[:space:]]*(POST|PUT|DELETE|PATCH) ]] ||
   [[ "$GH_PART" =~ [[:space:]](-f|-F|--field|--raw-field|--input)[[:space:]=] ]]; then
  exit 0
fi

# No write indicators — auto-allow the read.
echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
