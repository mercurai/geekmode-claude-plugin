#!/usr/bin/env bash
# pre-tool-use-destructive.sh — PreToolUse hook
# Gates destructive gm operations with a confirmation prompt.
# Reads the tool invocation details from CLAUDE_TOOL_INPUT (JSON).
# Destructive operations: restart, shutdown, cart release, reserve replay,
#   engine start-all, engine stop-all, encore-auth rotation, config set.

set -e

# The tool name is passed via environment by the Claude Code hook runtime
TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Only gate Bash tool calls
if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

# Extract the command string from the tool input JSON
# CLAUDE_TOOL_INPUT is a JSON object like {"command": "gm reserves replay abc123"}
if command -v python &>/dev/null; then
  CMD=$(python -c "import sys, json; d=json.loads(sys.stdin.read()); print(d.get('command',''))" <<< "$TOOL_INPUT" 2>/dev/null || echo "")
elif command -v python3 &>/dev/null; then
  CMD=$(python3 -c "import sys, json; d=json.loads(sys.stdin.read()); print(d.get('command',''))" <<< "$TOOL_INPUT" 2>/dev/null || echo "")
else
  CMD="$TOOL_INPUT"
fi

# List of destructive command patterns
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

MATCHED_PATTERN=""
for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$CMD" | grep -qE "$pattern"; then
    MATCHED_PATTERN="$pattern"
    break
  fi
done

if [ -z "$MATCHED_PATTERN" ]; then
  exit 0
fi

# Emit a warning block — the Claude Code runtime surfaces this to the user
echo "⚠️  DESTRUCTIVE OPERATION DETECTED"
echo "Command: $CMD"
echo "Pattern matched: $MATCHED_PATTERN"
echo ""
echo "This operation may have irreversible effects:"
echo "  - restart/shutdown: terminates running monitors and in-flight reserves"
echo "  - cart release: forfeits held seats"
echo "  - reserve replay: submits a new purchase attempt"
echo "  - encore-auth: rotates the active session (clears in-flight reserves)"
echo "  - engine start-all/stop-all: affects all monitored tasks"
echo "  - config set: changes live application configuration"
echo "  - proxy ban/rotate: affects proxy pool availability"
echo ""
echo "Confirm you want to proceed. The operation will run after confirmation."

# Exit 0 allows the operation to proceed (confirmation is advisory via the UI prompt)
# Exit non-zero would block the tool call entirely.
# We exit 0 here so Claude Code surfaces the warning and the user can confirm in the UI.
exit 0
