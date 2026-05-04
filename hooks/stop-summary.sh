#!/usr/bin/env bash
# stop-summary.sh — Stop hook
# Emits a summary of operations performed during the session.
# Reads from the timeline log written by post-tool-use-timeline.sh.

set -e

TIMELINE_FILE="${CLAUDE_SESSION_DIR:-$HOME/.claude}/geekmode-timeline.jsonl"

echo "=== geekmode-rust session summary ==="

if [ ! -f "$TIMELINE_FILE" ]; then
  echo "No destructive operations recorded this session."
  echo "==="
  exit 0
fi

ENTRY_COUNT=$(wc -l < "$TIMELINE_FILE" 2>/dev/null || echo 0)

if [ "$ENTRY_COUNT" -eq 0 ]; then
  echo "No destructive operations recorded this session."
  echo "==="
  exit 0
fi

echo "Destructive operations performed ($ENTRY_COUNT total):"
echo ""

python -c "
import json, sys

with open('$TIMELINE_FILE') as f:
    lines = [l.strip() for l in f if l.strip()]

for i, line in enumerate(lines, 1):
    try:
        entry = json.loads(line)
        ts = entry.get('ts', 'unknown')
        op = entry.get('op', 'unknown')
        cmd = entry.get('command', '')
        print(f'  {i}. [{ts}] {op}')
        print(f'     command: {cmd[:120]}')
    except json.JSONDecodeError:
        print(f'  {i}. (unparseable entry)')

print()
print('Review timeline: cat $TIMELINE_FILE | python -m json.tool')
" 2>/dev/null || {
  echo "(Could not parse timeline — raw entries follow)"
  cat "$TIMELINE_FILE"
}

# Rotate timeline: clear after summary so next session starts fresh
> "$TIMELINE_FILE" 2>/dev/null || true

echo "==="
