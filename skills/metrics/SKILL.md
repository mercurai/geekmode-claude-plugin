---
name: metrics
description: Render system metrics (CPU, memory, process stats) and business metrics (reserve rate, success rate, inventory coverage). Provides a human-readable dashboard summary.
triggers:
  - /metrics
  - "show metrics"
  - "system metrics"
  - "reserve metrics"
  - "business metrics"
  - "process stats"
  - "performance"
---

# Metrics Skill

Render system and business metrics for geekmode-rust.

## Steps

### 1. System metrics (processes)

```bash
gm metrics processes
```

Shows per-process: CPU %, memory (RSS/VSZ), thread count, uptime.

### 2. Process history (time series)

```bash
gm metrics processes history
```

Shows recent CPU/memory samples — useful for detecting spikes.

### 3. Infrastructure stats

```bash
gm stats infra
```

Shows: WebSocket message rates, HTTP request counts, queue depths, error rates.

### 4. Reserve business metrics

```bash
gm reserves stats
```

Shows: total attempts, success count, success rate, per-event breakdown, failure distribution.

### 5. Prometheus metrics (raw)

```bash
gm metrics                           # raw Prometheus text format
```

For integration with external monitoring. Parse with `grep` or `jq` for specific metric names.

## Dashboard Summary Format

After collecting metrics, render a structured summary:

```
Metrics Summary — <timestamp>
==============================
System
  CPU:     seatiq-monitor  2.3%  |  seatiq-probe  0.8%
  Memory:  seatiq-monitor  312 MB  |  seatiq-probe  48 MB

Infrastructure
  WS messages/s:  142    HTTP req/s:  38
  Queue depth:    0      Error rate:  0.2%

Business (last 1h)
  Reserve attempts:  24     Success rate:  87.5% (21/24)
  Failure breakdown:
    proxy_error:     2
    token_expired:   1

Events monitored:  6  (3 running / 2 paused / 1 error)
```

## Usage Notes

- Process metrics are polled from `/api/v1/metrics/processes` — they reflect the last sample interval.
- Business metrics from `gm reserves stats` are cumulative since last restart; note the window.
- For real-time metric streaming, use the `/watch` skill instead.
