# geekmode-claude-plugin marketplace

A Claude Code plugin marketplace for the [geekmode-rust](https://github.com/mercurai/geekmode-rust) ticket monitoring application. This repository hosts the `geekmode-rust` plugin, which provides specialized agents, skills, hooks, and an MCP server for managing the geekmode-rust sidecar from within Claude Code sessions.

The marketplace follows the canonical Claude Code layout: a `.claude-plugin/marketplace.json` index at the root points to individual plugins under `plugins/`. Claude Code resolves the plugin directory automatically when you run the marketplace add command.

## Install

Add the marketplace and install the plugin with two commands:

```
/plugin marketplace add mercurai/geekmode-claude-plugin
/plugin install geekmode-rust@geekmode-claude-plugin
```

## What's included

The `geekmode-rust` plugin bundles everything needed to operate the application from Claude Code:

| Component | Items |
|-----------|-------|
| Agents    | 6 — reserve-ops, monitor-ops, probe-ops, tmpt-ops, proxy-ops, logs-analyst |
| Skills    | 7 — `/tasks`, `/reserves`, `/probe`, `/logs`, `/watch`, `/health`, `/metrics` |
| Hooks     | 4 — SessionStart health check, PreToolUse guard, PostToolUse timeline, Stop summary |
| MCP       | 1 server — `gm-mcp` with 12 tools and 4 resource subscriptions |

See [plugins/geekmode-rust/README.md](plugins/geekmode-rust/README.md) for full usage instructions, skill reference, and version compatibility matrix.

## Repository layout

```
.claude-plugin/
  marketplace.json        # marketplace index (Claude Code reads this)
plugins/
  geekmode-rust/
    .claude-plugin/
      plugin.json         # plugin manifest
    agents/               # 6 agent definitions
    skills/               # 7 skill definitions
    commands/
    hooks/                # 4 hook scripts + hooks.json wiring
    mcp/                  # gm-mcp binary placeholder
    README.md             # plugin-level documentation
.github/                  # CI and release workflows
LICENSE
README.md                 # this file
```

## License

MIT — Copyright (c) Mercurai
