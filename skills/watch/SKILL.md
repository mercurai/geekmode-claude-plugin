---
name: watch
description: Subscribe to real-time WebSocket event streams from geekmode-rust via gm watch. Surfaces live reserve events, availability changes, health transitions, and log streams.
triggers:
  - /watch
  - "watch events"
  - "live stream"
  - "subscribe"
  - "real-time"
  - "watch reserves"
  - "watch health"
---

# Watch Skill

Subscribe to live event streams from the geekmode-rust WebSocket topics.

## Steps

### 1. Choose a topic to watch

```bash
gm watch reserves                    # live reserve events (attempts, outcomes)
gm watch availability                # inventory change events
gm watch health                      # component health transitions
gm watch logs                        # live log stream (same as gm logs tail)
gm watch all                         # unified stream of all topics
```

### 2. Filter the stream

```bash
gm watch reserves --event <event_id> # reserves for a specific event only
gm watch logs --level error          # error-level log events only
gm watch availability --event <event_id>
```

### 3. Set a watch duration

```bash
gm watch reserves --duration 60s     # watch for 60 seconds then exit
gm watch all --duration 5m           # unified stream for 5 minutes
```

If no `--duration` is given, the stream runs until interrupted. For diagnostic sessions, always set a duration to avoid blocking the terminal.

### 4. Pipe to a file for analysis

```bash
gm watch reserves --duration 5m > /tmp/reserve-stream.json
```

## Topic Reference

| Topic | Events emitted |
|-------|---------------|
| `reserves` | `reserve_attempt`, `reserve_success`, `reserve_failed` |
| `availability` | `inventory_update`, `section_oos`, `section_available` |
| `health` | `component_up`, `component_down`, `component_degraded` |
| `logs` | Log lines at the requested level |
| `all` | All of the above multiplexed |

## Usage Notes

- `gm watch` connects to the local WebSocket server (`ws://localhost:9090/ws`).
- The server must be running; check with `gm health readyz` first.
- Events are emitted as newline-delimited JSON — pipe to `jq` for pretty-printing.
- For event-scoped monitoring, always filter by `--event` to reduce noise.
