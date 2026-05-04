---
name: health
description: Run gm health all, interpret component status, surface failures, and provide a concise summary with actionable next steps.
triggers:
  - /health
  - "check health"
  - "system health"
  - "health check"
  - "is it running"
  - "what's the status"
---

# Health Skill

Run a full system health check and summarize component status.

## Steps

### 1. Quick liveness check

```bash
gm health readyz
```

If this fails, the server is not reachable — check that the geekmode-rust process is running.

### 2. Full component health

```bash
gm health all
```

Reports status for all components: engine, proxy pools, auth, WebSocket, database, and downstream.

### 3. Deep diagnostic (when all-check shows degraded)

```bash
gm health deep
```

Includes sub-checks within each component (e.g., auth token age, proxy pool ratios, WS latency).

## Interpreting Results

**Status values:**

| Status | Meaning | Action |
|--------|---------|--------|
| `ok` | Healthy | None |
| `degraded` | Functional but reduced capacity | Investigate the sub-check |
| `down` | Component is not functional | Immediate action required |
| `unknown` | Cannot reach component | Check connectivity |

**Component actions:**

| Component | Degraded/Down → |
|-----------|----------------|
| `proxy` | Run `gm proxy pools` — check active ratio |
| `auth` | Run `gm control encore-auth` — rotate session |
| `engine` | Check `gm tasks list` — look for error-state tasks |
| `ws` | Check downstream WebSocket connection |
| `database` | Check disk space and Postgres process |
| `monitor` | Check `gm tasks list` for stalled monitors |

## Summary Format

After running health checks, emit:

```
Health Summary — <timestamp>
============================
Overall: <ok|degraded|down>

Components:
  ✓ engine     — ok
  ✓ proxy      — ok (42/50 active)
  ✗ auth       — degraded (token age: 23h)
  ✓ ws         — ok
  ✓ database   — ok

Recommended actions:
  1. Rotate auth session: gm control encore-auth
```
