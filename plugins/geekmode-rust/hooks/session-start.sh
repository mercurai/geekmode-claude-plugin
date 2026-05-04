#!/usr/bin/env bash
# session-start.sh — SessionStart hook
# Calls gm health readyz at session start and surfaces failures upfront.
# If the server is unreachable, emits a warning but does not block the session.

set -e

GM="${GM_BIN:-gm}"

echo "=== geekmode-rust session health check ==="

# Quick liveness check
if ! command -v "$GM" &>/dev/null; then
  echo "[WARN] gm CLI not found (expected at: $GM). Skipping health check."
  echo "       Set GM_BIN=/path/to/gm or add gm to PATH."
  exit 0
fi

READYZ_OUTPUT=$("$GM" health readyz 2>&1) || READYZ_EXIT=$?

if [ "${READYZ_EXIT:-0}" -ne 0 ]; then
  echo "[WARN] geekmode-rust server is not reachable."
  echo "       readyz output: $READYZ_OUTPUT"
  echo "       Operations requiring the server will fail. Start geekmode-rust first."
  echo "       (session continues — server-independent tasks are still available)"
  exit 0
fi

echo "[OK] Server reachable"

# Full component status (non-fatal on failure — just surface it)
HEALTH_OUTPUT=$("$GM" health all 2>&1) || true

echo "$HEALTH_OUTPUT"

# Check for any non-ok components and surface them
DEGRADED=$(echo "$HEALTH_OUTPUT" | grep -iE '(degraded|down|error)' || true)
if [ -n "$DEGRADED" ]; then
  echo ""
  echo "[WARN] Degraded components detected:"
  echo "$DEGRADED"
  echo "       Run /health for full diagnostics."
fi

echo "==="
