#!/usr/bin/env python
"""PreToolUse + PostToolUse hook: guard destructive `gm` operations from one script.

Reads the harness payload from stdin (`hook_event_name`, `tool_name`, `tool_input`,
`tool_response`), which is the documented hook contract. The two shell scripts this replaces read
`CLAUDE_TOOL_NAME` from the environment, which the harness never sets, so they exited on every call
without inspecting a command, and paid two shell spawns plus a `grep` loop to do it.

  PreToolUse  - a destructive `gm` command gets an `additionalContext` warning. Advisory only:
                the call is never blocked; the model sees the warning and confirms with the user.
  PostToolUse - a destructive `gm` command that ran is appended to
                `${CLAUDE_SESSION_DIR:-~/.claude}/geekmode-timeline.jsonl`, which
                stop-summary.sh reads at the end of the session.

Fails open: malformed stdin, another tool, an interrupted call, or no match exits 0 with no
output. Pure stdlib.
"""

import json
import os
import re
import sys
from datetime import datetime, timezone

# The same ten patterns the shell scripts carried, matched as extended-regex substrings.
DESTRUCTIVE_PATTERNS = (
    "gm control restart",
    "gm control shutdown",
    "gm carts release",
    "gm reserves replay",
    "gm engine start-all",
    "gm engine stop-all",
    "gm control encore-auth",
    "gm config set",
    "gm proxy pools.*ban",
    "gm proxy pools.*rotate",
)

WARNING = """DESTRUCTIVE gm OPERATION DETECTED
Command: {command}
Pattern matched: {pattern}

This operation may have irreversible effects:
  - restart/shutdown: terminates running monitors and in-flight reserves
  - cart release: forfeits held seats
  - reserve replay: submits a new purchase attempt
  - encore-auth: rotates the active session (clears in-flight reserves)
  - engine start-all/stop-all: affects all monitored tasks
  - config set: changes live application configuration
  - proxy ban/rotate: affects proxy pool availability

Confirm with the user before proceeding."""


def matched_pattern(command: str):
    for pattern in DESTRUCTIVE_PATTERNS:
        if re.search(pattern, command):
            return pattern
    return None


def timeline_path() -> str:
    base = os.environ.get("CLAUDE_SESSION_DIR") or os.path.expanduser("~/.claude")
    return os.path.join(base, "geekmode-timeline.jsonl")


def warn(command: str, pattern: str) -> None:
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "additionalContext": WARNING.format(command=command, pattern=pattern),
        }
    }
    sys.stdout.write(json.dumps(output) + "\n")


def record(command: str, pattern: str, response) -> None:
    if isinstance(response, dict) and (response.get("interrupted") or response.get("is_error")):
        return
    entry = {
        "ts": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "op": pattern,
        "command": command,
        "exit_code": response.get("exit_code") if isinstance(response, dict) else None,
    }
    try:
        with open(timeline_path(), "a", encoding="utf-8") as handle:
            handle.write(json.dumps(entry) + "\n")
    except OSError:
        pass


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        return
    if not isinstance(data, dict) or data.get("tool_name") != "Bash":
        return
    tool_input = data.get("tool_input")
    command = tool_input.get("command", "") if isinstance(tool_input, dict) else ""
    pattern = matched_pattern(command)
    if not pattern:
        return
    event = data.get("hook_event_name")
    if event == "PreToolUse":
        warn(command, pattern)
    elif event == "PostToolUse":
        record(command, pattern, data.get("tool_response"))


if __name__ == "__main__":
    main()
