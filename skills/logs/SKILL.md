---
name: logs
description: Query and tail application logs by run_id, level, module, or time range. Always confirm the run_id is current before reading. Never read raw log files directly.
triggers:
  - /logs
  - "show logs"
  - "check logs"
  - "tail logs"
  - "find errors"
  - "trace run"
  - "log errors"
---

# Logs Skill

Query geekmode-rust application logs safely.

## IMPORTANT: Run ID Protocol

**Always confirm a run_id before reading.** Old logs may be stale or from a different run. Never read raw log files from disk — use `gm logs *` commands exclusively.

## Steps

### 1. Get recent errors (default triage)

```bash
gm logs list --level error --since 15m
```

### 2. Widen the time window if needed

```bash
gm logs list --level error --since 1h
gm logs list --level warn --since 30m
```

### 3. Filter by module

```bash
gm logs list --module reserve --level error --since 1h
gm logs list --module proxy --since 30m
gm logs list --module monitor --level warn --since 1h
```

Available modules: `reserve`, `proxy`, `monitor`, `auth`, `probe`, `ws`, `cart`, `engine`

### 4. Trace a specific run

First confirm the run exists:

```bash
gm logs list --run-id <id> --limit 1
```

Then fetch the full trace:

```bash
gm logs list --run-id <id>
```

### 5. Live log stream

```bash
gm logs tail --level error           # live errors
gm logs tail --level warn            # live warnings and errors
```

Exit after a brief window — do not leave tailing indefinitely.

### 6. Limit output volume

```bash
gm logs list --limit 50              # cap at 50 lines
gm logs list --level error --since 1h --limit 100
```

## Interpreting Results

- Quote error messages verbatim when reporting — do not paraphrase
- Group repeated errors by message prefix to identify patterns
- Note the wall-clock window searched (e.g., "last 15 minutes") in the report
- Cross-reference error timestamps with reserve timestamps for failure investigations
