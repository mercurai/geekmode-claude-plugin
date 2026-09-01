"""Behavioural tests for hooks/gm-destructive-guard.py, run exactly as the harness runs it:
payload on stdin, one subprocess per call. Stdlib only: `python -m unittest discover -s tests`."""

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

GUARD = Path(__file__).resolve().parents[1] / "plugins" / "geekmode-rust" / "hooks" / "gm-destructive-guard.py"


def run(payload: str, extra_env=None) -> subprocess.CompletedProcess:
    env = dict(os.environ)
    env.update(extra_env or {})
    return subprocess.run(
        [sys.executable, str(GUARD)], input=payload, capture_output=True, text=True, timeout=20, env=env
    )


def payload(event: str, command: str, tool: str = "Bash", response=None) -> str:
    data = {"hook_event_name": event, "tool_name": tool, "tool_input": {"command": command}}
    if response is not None:
        data["tool_response"] = response
    return json.dumps(data)


class PreToolUse(unittest.TestCase):
    def test_destructive_command_gets_a_warning_context(self):
        result = run(payload("PreToolUse", "gm reserves replay abc123"))
        self.assertEqual(result.returncode, 0)
        block = json.loads(result.stdout)["hookSpecificOutput"]
        self.assertEqual(block["hookEventName"], "PreToolUse")
        self.assertIn("gm reserves replay", block["additionalContext"])
        self.assertIn("abc123", block["additionalContext"])

    def test_regex_pattern_matches_proxy_ban(self):
        result = run(payload("PreToolUse", "gm proxy pools residential ban 1.2.3.4"))
        self.assertIn("gm proxy pools.*ban", result.stdout)

    def test_plain_command_is_silent(self):
        result = run(payload("PreToolUse", "gm tasks list"))
        self.assertEqual((result.returncode, result.stdout), (0, ""))

    def test_other_tool_is_silent(self):
        result = run(payload("PreToolUse", "gm control restart", tool="Read"))
        self.assertEqual((result.returncode, result.stdout), (0, ""))


class PostToolUse(unittest.TestCase):
    def test_destructive_command_is_recorded_to_the_timeline(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = run(
                payload("PostToolUse", "gm control restart", response={"exit_code": 0}),
                {"CLAUDE_SESSION_DIR": tmp},
            )
            self.assertEqual((result.returncode, result.stdout), (0, ""))
            lines = (Path(tmp) / "geekmode-timeline.jsonl").read_text(encoding="utf-8").splitlines()
            self.assertEqual(len(lines), 1)
            entry = json.loads(lines[0])
            self.assertEqual(entry["op"], "gm control restart")
            self.assertEqual(entry["command"], "gm control restart")
            self.assertEqual(entry["exit_code"], 0)
            self.assertTrue(entry["ts"].endswith("Z"))

    def test_interrupted_call_is_not_recorded(self):
        with tempfile.TemporaryDirectory() as tmp:
            run(
                payload("PostToolUse", "gm control shutdown", response={"interrupted": True}),
                {"CLAUDE_SESSION_DIR": tmp},
            )
            self.assertFalse((Path(tmp) / "geekmode-timeline.jsonl").exists())

    def test_plain_command_writes_nothing(self):
        with tempfile.TemporaryDirectory() as tmp:
            run(payload("PostToolUse", "gm tasks list"), {"CLAUDE_SESSION_DIR": tmp})
            self.assertFalse((Path(tmp) / "geekmode-timeline.jsonl").exists())


class Robustness(unittest.TestCase):
    def test_malformed_stdin_fails_open(self):
        result = run("{not json")
        self.assertEqual((result.returncode, result.stdout), (0, ""))

    def test_empty_stdin_fails_open(self):
        result = run("")
        self.assertEqual((result.returncode, result.stdout), (0, ""))


if __name__ == "__main__":
    unittest.main()
