# MCP Server — gm-mcp

The `gm-mcp` binary is the MCP server for geekmode-rust. It exposes 12 MCP tools and 4 resource subscriptions, with prepare/commit gating on all destructive operations.

## Binary Source

The `gm-mcp` binary is **not bundled** in this plugin repository. It ships as a release artifact of [geekmode-rust](https://github.com/mercurai/geekmode-rust).

To install:

1. Download the latest `gm-mcp` binary from the [geekmode-rust releases page](https://github.com/mercurai/geekmode-rust/releases/latest).
   - Windows: `gm-mcp-x86_64-pc-windows-msvc.exe` → rename to `gm-mcp.exe`
   - Linux: `gm-mcp-x86_64-unknown-linux-musl` → rename to `gm-mcp`
   - macOS: `gm-mcp-aarch64-apple-darwin` → rename to `gm-mcp`

2. Place the binary in this directory (`mcp/`):
   ```
   geekmode-claude-plugin/
   └── mcp/
       ├── README.md        (this file)
       ├── gm-mcp.exe       (Windows)
       └── gm-mcp           (Linux/macOS)
   ```

3. Make it executable (Linux/macOS):
   ```bash
   chmod +x mcp/gm-mcp
   ```

## Version Compatibility

| Plugin version | geekmode-rust version |
|---------------|----------------------|
| v0.2.0        | ≥ v0.6.15            |

The MCP tool surface is stable from geekmode-rust v0.6.15 onward. Earlier versions may lack some tools.

## Authentication

`gm-mcp` authenticates against the local geekmode-rust API server using an API key.

Set your API key before first use:

```bash
gm config set --api-key <your-api-key>
```

The key is stored in the geekmode-rust config file (`~/.config/geekmode/config.toml` on Linux/macOS, `%APPDATA%\geekmode\config.toml` on Windows). `gm-mcp` reads it automatically on startup.

To verify authentication is working:

```bash
gm-mcp --check-auth
```

## Adding to Claude Code

After placing the binary and setting the API key, register the MCP server:

```bash
# Windows
claude mcp add geekmode-rust -- "C:/path/to/geekmode-claude-plugin/mcp/gm-mcp.exe"

# Linux / macOS
claude mcp add geekmode-rust -- "/path/to/geekmode-claude-plugin/mcp/gm-mcp"
```

Or via the plugin manifest (automatic when the plugin is installed):

```json
{
  "mcpServers": [
    {
      "name": "geekmode-rust",
      "command": "${PLUGIN_ROOT}/mcp/gm-mcp.exe",
      "args": []
    }
  ]
}
```

## MCP Tools Provided

The server exposes tools corresponding to the geekmode-rust control API. Destructive operations require a prepare/commit flow — the tool returns a `confirm_token` that must be passed back to execute the operation.

See [geekmode-rust docs/mcp-tool-mapping.md](https://github.com/mercurai/geekmode-rust/blob/master/docs/mcp-tool-mapping.md) for the full endpoint → tool table.

## Resource Subscriptions

`gm-mcp` provides 4 live resource subscriptions via MCP resource protocol:

| Resource URI | Description |
|-------------|-------------|
| `geekmode://reserves/live` | Real-time reserve events |
| `geekmode://availability/{event_id}` | Live inventory updates for an event |
| `geekmode://health/status` | Component health transitions |
| `geekmode://logs/stream` | Live log stream |
