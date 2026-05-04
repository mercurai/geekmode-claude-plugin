---
name: reserves
description: List, inspect, and replay reserves. Filter by event, inspect failure reasons, view per-event stats, and replay failed reserves.
triggers:
  - /reserves
  - "list reserves"
  - "show reserves"
  - "reserve stats"
  - "replay reserve"
  - "failed reserves"
---

# Reserves Skill

Inspect and manage reserve history for geekmode-rust.

## Steps

### 1. List recent reserves

```bash
gm reserves list
```

Shows: reserve ID, event ID, status (success/failed/in_flight), seat count, timestamp.

### 2. Filter by event

```bash
gm reserves list --event <event_id>
```

### 3. Inspect a reserve

```bash
gm reserves get <id>
```

Shows full detail: seats, price zone, section, row data, failure reason (if failed), proxy used.

### 4. View aggregate stats

```bash
gm reserves stats
```

Shows: total attempts, success rate, common failure reasons, per-event breakdown.

### 5. Replay a failed reserve

Before replaying, confirm:
1. The failure reason is transient (proxy error, token expired) — not structural
2. The proxy pool is healthy: `gm proxy pools reserve stats`
3. Auth is valid: `gm health deep` → auth sub-check

Then replay:

```bash
gm reserves replay <id>
```

**This is a destructive operation** — it submits a new reserve attempt with the same parameters. Confirm intent before running.

## Usage Notes

- Only replay reserves with transient failure reasons. Do not replay reserves that failed due to `no_seats` or `price_mismatch` — those reflect genuine availability.
- A successful replay creates a new reserve record; the original failed record is retained.
- For cart state after a successful reserve, use the `/tasks` skill to check cart status.
