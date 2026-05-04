---
name: probe
description: Kick off on-demand probes, read probe results (seat map, section availability, open seats), and correlate against monitor availability snapshots.
triggers:
  - /probe
  - "run probe"
  - "probe event"
  - "check seats"
  - "open seats"
  - "section availability"
---

# Probe Skill

Trigger and inspect probes for a specific event.

## Steps

### 1. Check for existing probe results

```bash
gm map open-seats <event_id>
gm map section-availability <event_id>
```

If results are recent (check timestamp), skip to step 3.

### 2. Check in-flight probe jobs

```bash
gm jobs list
```

Look for a probe job for the target event. If one is running, wait for completion.

### 3. Read probe results

```bash
gm map open-seats <event_id>          # open seat list with section/row/seat
gm map seats <event_id>               # full seat layout
gm map section-availability <event_id> # per-section availability summary
gm map venue <event_id>               # venue geometry (for section names)
```

### 4. Compare against monitor snapshot

```bash
gm availability <event_id>
```

Compare the probe's open-seat count against the monitor's current inventory snapshot. Discrepancies indicate stale monitor data or a timing difference.

### 5. Inspect a specific job

```bash
gm jobs get <id>
```

Shows probe job output, duration, proxy used, and completion status.

## Usage Notes

- Probe is a **read-only** diagnostic — it does not trigger reserves.
- Probe runs as a separate process. Results are available after job completion.
- Always check the job completion timestamp before treating results as current.
- For geometry data needed by the reserve payload (row field), probe map data is the authoritative source.
