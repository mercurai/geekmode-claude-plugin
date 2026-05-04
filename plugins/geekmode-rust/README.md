# geekmode-claude-plugin

Claude Code plugin for managing the [geekmode-rust](https://github.com/mercurai/geekmode-rust) ticket monitoring application.

Bundles agents, skills, hooks, and MCP server integration into a single install.

## Install

```sh
claude plugins install mercurai/geekmode-claude-plugin
```

## Quickstart

1. Install the plugin:
   ```sh
   claude plugins install mercurai/geekmode-claude-plugin
   ```

2. Place the `gm-mcp` binary in the `mcp/` directory (see [mcp/README.md](mcp/README.md)):
   ```sh
   # Download from https://github.com/mercurai/geekmode-rust/releases/latest
   # Windows: rename to gm-mcp.exe and place in mcp/
   # Linux/macOS: rename to gm-mcp, chmod +x, and place in mcp/
   ```

3. Set your API key:
   ```sh
   gm config set --api-key <your-api-key>
   ```

4. Start a Claude Code session. The `session-start` hook will automatically run a health check against the running geekmode-rust server.

5. Use the built-in skills:
   ```
   /health    — system health summary
   /tasks     — manage monitoring tasks
   /reserves  — list and replay reserves
   /logs      — query application logs
   /probe     — inspect seat availability
   /watch     — live event streams
   /metrics   — system and business metrics
   ```

## What this plugin provides

| Component | Items | Description |
|-----------|-------|-------------|
| Agents | 6 | Specialized agents for reserve, monitor, probe, auth, proxy, and log operations |
| Skills | 7 | `/tasks`, `/reserves`, `/probe`, `/logs`, `/watch`, `/health`, `/metrics` |
| Hooks | 4 | SessionStart health check, PreToolUse guard, PostToolUse timeline, Stop summary |
| MCP | 1 server | `gm-mcp` — 12 MCP tools + 4 resource subscriptions |

### Agents

| Agent | Purpose |
|-------|---------|
| `reserve-ops` | Task CRUD, reserve inspection and replay, cart management |
| `monitor-ops` | Monitor health diagnosis, availability trend analysis |
| `probe-ops` | On-demand probes, seat map inspection, cross-reference against live TM data |
| `tmpt-ops` | TMPT token state, EPS captcha, encore-auth session rotation |
| `proxy-ops` | Proxy pool health, ban/unban, rotation |
| `logs-analyst` | Log search, error surfacing, request tracing by run_id |

### Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `session-start.sh` | SessionStart | Calls `gm health readyz`, surfaces failures upfront |
| `pre-tool-use-destructive.sh` | PreToolUse | Warns before destructive `gm` operations |
| `post-tool-use-timeline.sh` | PostToolUse | Logs destructive ops to session timeline |
| `stop-summary.sh` | Stop | Emits summary of operations performed |

## Version Compatibility

| Plugin version | geekmode-rust version |
|---------------|----------------------|
| v0.2.0        | ≥ v0.6.15            |
| v0.1.0        | scaffolding only     |

## Development

```sh
# Validate JSON manifests
node -e "['plugin.json','marketplace.json'].forEach(f => { JSON.parse(require('fs').readFileSync(f,'utf8')); console.log(f + ' OK'); })"
```

## References

- [geekmode-rust#542](https://github.com/mercurai/geekmode-rust/issues/542) — parent tracking issue
- [geekmode-rust](https://github.com/mercurai/geekmode-rust) — the application this plugin manages
- [mcp/README.md](mcp/README.md) — MCP server setup and binary sourcing

## License

MIT — Copyright (c) Mercurai
