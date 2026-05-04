#!/usr/bin/env bash
# post-tool-use-timeline.sh — PostToolUse hook
# Appends a timeline entry to the session doc when a destructive gm op succeeds.
# Writes to ~/.claude/geekmode-timeline.jsonl for post-session review.

set -e

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
TOOL_EXIT="${CLAUDE_TOOL_EXIT_CODE:-0}"

# Only process Bash tool calls that succeeded
if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

if [ "$TOOL_EXIT" != "0" ]; then
  exit 0
fi

# Extract command
if command -v python &>/dev/null; then
  CMD=$(python -c "import sys, json; d=json.loads(sys.stdin.read()); print(d.get('command',''))" <<< "$TOOL_INPUT" 2>/dev/null || echo "")
else
  CMD="$TOOL_INPUT"
fi

# Only log destructive operations
DESTRUCTIVE_PATTERNS=(
  "gm control restart"
  "gm control shutdown"
  "gm carts release"
  "gm reserves replay"
  "gm engine start-all"
  "gm engine stop-all"
  "gm control encore-auth"
  "gm config set"
  "gm proxy pools.*ban"
  "gm proxy pools.*rotate"
)

MATCHED=""
for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$CMD" | grep -qE "$pattern"; then
    MATCHED="$pattern"
    break
  fi
done

if [ -z "$MATCHED" ]; then
  exit 0
fi

TIMELINE_FILE="${CLAUDE_SESSION_DIR:-$HOME/.claude}/geekmode-timeline.jsonl"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Append JSON timeline entry
python -c "
import json, sys
entry = {
    'ts': '$TIMESTAMP',
    'op': '$MATCHED',
    'command': '''$CMD''',
    'exit_code': $TOOL_EXIT
}
print(json.dumps(entry))
" >> "$TIMELINE_FILE" 2>/dev/null || true

exit 0
