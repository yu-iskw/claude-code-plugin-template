# Multi-Platform AI Plugin Monorepo Template

Template repository for bootstrapping high-quality plugins for **Claude Code**, **Cursor**, and **OpenAI Codex** with shared CI/CD and testing infrastructure.

## Key Features

- **Multi-Platform Support**: Build plugins once, deploy to Claude Code, Cursor, and Codex with platform-specific manifest generation.
- **Standard Plugin Layout**: Follows best practices for Skills, Agents, Hooks, MCP, and LSP.
- **Monorepo Ready**: Designed to host multiple plugins under the `plugins/` directory.
- **Comprehensive Examples**: The `hello-world` plugin demonstrates every available extension point across all platforms.
- **Shared CI/CD**: Unified quality checks via `trunk` and GitHub Actions.
- **Integration Tests**: Automated smoke tests that validate manifest schemas, component discovery, and **plugin installation** (marketplace add + install + list/validate) across all plugins.
- **Build-Time Manifest Generation**: Generate platform-specific `plugin.json` manifests from a single `plugin-config.json` source file.

## Repository Layout

```text
.
├── plugins/                     # Container for all plugins
│   └── hello-world/             # Comprehensive sample plugin
│       ├── .claude-plugin/      # Plugin metadata (plugin.json)
│       ├── agents/              # Custom agent definitions
│       ├── skills/              # Model-invoked skills (SKILL.md)
│       ├── hooks/               # Event hook configurations
│       ├── .mcp.json            # MCP server configuration
│       └── .lsp.json            # LSP server configuration
├── integration_tests/           # Shared testing harness
│   ├── run.sh                   # Test orchestrator (scans plugins/)
│   ├── validate-manifest.sh     # Manifest JSON schema validator
│   └── ...
├── .github/workflows/           # GitHub Actions (Lint, Integration Tests)
├── Makefile                     # Task runner
└── README.md
```

## Quickstart

1.  **Create a new repository** from this template.
2.  **Explore the sample plugin** in `plugins/hello-world/` to see how components are defined.
3.  **Generate platform-specific manifests**:
    ```bash
    make generate-manifests
    make generate-marketplace
    ```
4.  **Validate configurations**:
    ```bash
    make validate-manifests
    make validate-marketplace
    ```
5.  **Run local checks**:
    ```bash
    make lint
    make test-integration-docker
    ```

## Multi-Platform Development

This template supports developing plugins for three platforms simultaneously:

| Platform | Manifest | Marketplace | Status |
|----------|----------|-------------|--------|
| **Claude Code** | `.claude-plugin/plugin.json` | `.claude-plugin/marketplace.json` | ✅ Full support |
| **Cursor** | `.cursor-plugin/plugin.json` | `.cursor-plugin/marketplace.json` | ✅ Full support |
| **OpenAI Codex** | `.codex-plugin/plugin.json` | `.codex-plugin/marketplace.json` | ✅ Full support |

### Getting Started with Multi-Platform

1. Create your plugin with a **unified configuration** in `plugin-config.json`
2. Run `make generate-manifests` to create platform-specific plugin manifests
3. Run `make generate-marketplace` to create marketplace configurations
4. Test on each platform using their respective CLIs
5. Deploy to each platform's marketplace

See [**MULTI_PLATFORM_GUIDE.md**](./docs/MULTI_PLATFORM_GUIDE.md) for detailed instructions on:
- Plugin configuration format
- Cross-platform component compatibility
- Platform-specific limitations and workarounds
- Best practices for multi-platform development

See [**MARKETPLACE_DEPLOYMENT_GUIDE.md**](./docs/MARKETPLACE_DEPLOYMENT_GUIDE.md) for:
- Marketplace metadata configuration
- Asset management (icons, screenshots)
- Step-by-step submission to each marketplace
- Publishing best practices

## Development

### Adding a New Plugin

Create a new directory in `plugins/` following the [Standard Plugin Layout](https://code.claude.com/docs/en/plugins-reference#standard-plugin-layout):

- `plugins/<name>/.claude-plugin/plugin.json`: Required manifest.
- `plugins/<name>/skills/`: Agent Skills folder.
- `plugins/<name>/agents/`: Subagent markdown files.
- `plugins/<name>/hooks/`: Event hook configurations.
- `plugins/<name>/.mcp.json`: MCP configurations.
- `plugins/<name>/.lsp.json`: LSP configurations.

### Testing

The integration test runner (`./integration_tests/run.sh`) automatically discovers all directories in `plugins/` that contain a `.claude-plugin/plugin.json` file.

- Run all tests: `./integration_tests/run.sh`
- Verbose output: `./integration_tests/run.sh --verbose`
- Skip loading tests (if Claude CLI is not installed): `./integration_tests/run.sh --skip-loading`

Docker integration tests (`make test-integration-docker`) run the same suite inside a container and additionally run a **plugin install** test: they add the workspace as a marketplace, install each plugin with `claude plugin install`, and verify with `claude plugin list`. The same Docker flow runs in CI (job `plugin-install-docker`).

## CI/CD

- **Trunk Check**: Runs linters and static analysis on every PR.
- **Integration Tests**: Automatically validates every plugin in the `plugins/` directory.

## License

Apache License 2.0. See `LICENSE`.
