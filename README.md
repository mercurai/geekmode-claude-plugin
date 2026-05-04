# geekmode-claude-plugin

Claude Code plugin for managing the [geekmode-rust](https://github.com/mercurai/geekmode-rust) ticket monitoring application.

Bundles agents, skills, hooks, and MCP server integration into a single install.

> **Status:** Phase 1 bootstrap — scaffolding only. Agents, skills, and MCP wiring are implemented in subsequent phases (see [geekmode-rust#542](https://github.com/mercurai/geekmode-rust/issues/542)).

## Install

```sh
# Once published:
claude plugins install mercurai/geekmode-claude-plugin
```

## What this plugin provides

| Component | Description |
|-----------|-------------|
| Agents | `reserve-ops`, `monitor-ops`, `probe-ops`, `logs-analyst` (Phase 2) |
| Skills | `/tasks`, `/reserves`, `/probe`, `/logs`, `/health` (Phase 3) |
| Hooks | SessionStart health check, PreToolUse guard for destructive ops (Phase 4) |
| MCP | `gm-mcp` server auto-registration (Phase 5) |

## Development

```sh
# Validate JSON manifests
node -e "['plugin.json','marketplace.json'].forEach(f => { JSON.parse(require('fs').readFileSync(f,'utf8')); console.log(f + ' OK'); })"
```

## References

- [geekmode-rust#542](https://github.com/mercurai/geekmode-rust/issues/542) — parent tracking issue
- [geekmode-rust](https://github.com/mercurai/geekmode-rust) — the application this plugin manages

## License

MIT — Copyright (c) Mercurai
