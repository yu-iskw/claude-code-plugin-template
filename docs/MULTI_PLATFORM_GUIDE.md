# Multi-Platform Plugin Development Guide

This guide covers developing plugins for Claude Code, Cursor, and OpenAI Codex from a single source.

## Overview

All three platforms share similar extension models but with different manifest formats and naming conventions:

| Aspect | Claude Code | Cursor | Codex |
|--------|-------------|--------|-------|
| **Manifest Dir** | `.claude-plugin/` | `.cursor-plugin/` | `.codex-plugin/` |
| **Manifest File** | `plugin.json` | `plugin.json` | `plugin.json` |
| **Skills** | ✅ Supported | ✅ Supported | ✅ Required |
| **Agents** | ✅ Supported | ✅ Supported | ❌ N/A |
| **Hooks** | ✅ Supported | ✅ Supported | ❌ N/A |
| **MCP Servers** | ✅ Supported | ✅ Supported | ✅ Supported |
| **LSP Servers** | ✅ Supported | ❌ N/A | ❌ N/A |

## Plugin Configuration Format

Define your plugin once using `plugin-config.json` in the plugin root:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "A cross-platform plugin",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "license": "Apache-2.0",
  "repository": "https://github.com/you/repo",
  "homepage": "https://your-site.com",
  
  "platforms": {
    "claude": {
      "enabled": true,
      "mcpServers": "./.mcp.json",
      "lspServers": "./.lsp.json"
    },
    "cursor": {
      "enabled": true
    },
    "codex": {
      "enabled": true,
      "skills": "./skills/"
    }
  },
  
  "components": {
    "skills": {
      "enabled": true,
      "path": "./skills"
    },
    "agents": {
      "enabled": true,
      "path": "./agents"
    },
    "hooks": {
      "enabled": true,
      "path": "./hooks/hooks.json"
    },
    "mcp": {
      "enabled": true,
      "path": "./.mcp.json"
    },
    "lsp": {
      "enabled": true,
      "path": "./.lsp.json"
    }
  }
}
```

## Plugin Directory Structure

A multi-platform plugin follows this structure:

```
my-plugin/
├── plugin-config.json              # Single source of truth for all platforms
├── .claude-plugin/                 # Generated for Claude Code
│   └── plugin.json                 # Auto-generated manifest
├── .cursor-plugin/                 # Generated for Cursor
│   └── plugin.json                 # Auto-generated manifest
├── .codex-plugin/                  # Generated for Codex
│   └── plugin.json                 # Auto-generated manifest
├── skills/                         # Shared skill definitions
│   ├── skill1/
│   │   └── SKILL.md
│   └── skill2/
│       └── SKILL.md
├── agents/                         # Claude Code & Cursor agents
│   ├── agent1.md
│   └── agent2.md
├── hooks/                          # Event hooks
│   └── hooks.json
├── rules/                          # Cursor-specific rules (optional)
│   └── rules.json
├── .mcp.json                       # MCP server configuration
├── .lsp.json                       # Claude Code LSP configuration
├── assets/                         # Icons, logos, screenshots
│   ├── icon.png
│   ├── logo.png
│   └── screenshots/
└── README.md
```

## Building Cross-Platform Manifests

Use the build script to generate platform-specific manifests:

```bash
# Generate manifests for all enabled platforms
./scripts/generate-manifests.sh

# Generate for specific platform
./scripts/generate-manifests.sh --platform claude
./scripts/generate-manifests.sh --platform cursor
./scripts/generate-manifests.sh --platform codex

# Validate all manifests
./scripts/validate-manifests.sh
```

## Component Compatibility

### Skills (Shared)

Skills are directly portable across all platforms. Define once in `skills/`:

```
skills/
├── my-skill/
│   ├── SKILL.md          # Shared frontmatter and instructions
│   ├── scripts/          # Optional scripts
│   └── assets/           # Optional assets
```

**SKILL.md format** (compatible across all platforms):

```markdown
---
title: My Skill
description: What this skill does
type: tool|workflow|integration
tags: [tag1, tag2]
---

# My Skill

Instructions for using this skill...
```

### Agents (Claude Code & Cursor)

Agents are platform-specific. Cursor and Claude Code agents use similar Markdown syntax:

```
agents/
├── claude-expert.md          # Claude Code agent
└── cursor-specialist.md      # Cursor agent (identical format)
```

**Agent frontmatter** (both platforms):

```markdown
---
name: Expert Agent
description: Provides expert guidance
capabilities: [code_analysis, refactoring]
---

Agent instructions...
```

### Hooks (Claude Code & Cursor)

Hooks trigger on specific events. Format is platform-specific:

```json
{
  "claude": {
    "command:start": "./on-command-start.sh"
  },
  "cursor": {
    "command:start": "./on-command-start.sh"
  }
}
```

### MCP Servers (All Platforms)

MCP servers are identical across platforms. Configure in `.mcp.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["./server.js"]
    }
  }
}
```

### LSP Servers (Claude Code Only)

LSP is only supported by Claude Code. Configure in `.lsp.json`:

```json
{
  "lspServers": {
    "my-language": {
      "command": "node",
      "args": ["./lsp-server.js"]
    }
  }
}
```

## Testing Multi-Platform Plugins

### Local Testing

```bash
# Test Claude Code
make test-integration-docker

# Test individual plugin
./integration_tests/run.sh --plugin my-plugin

# Validate manifests
./scripts/validate-manifests.sh
```

### Platform-Specific Testing

**Claude Code:**
```bash
# Install locally via Claude Code CLI
claude plugin install ./my-plugin

# Verify installation
claude plugin list
```

**Cursor:**
```bash
# Install Cursor plugin
# See https://cursor.com/docs/plugins#installing-plugins
```

**Codex:**
```bash
# Install Codex plugin
# See https://developers.openai.com/codex/plugins/installing-plugins
```

## Migration Path

If migrating from single-platform to multi-platform:

1. **Create `plugin-config.json`** in your plugin root
2. **Run `generate-manifests.sh`** to create platform-specific manifests
3. **Test** on all target platforms
4. **Update documentation** to mention multi-platform support

## Examples

See `plugins/hello-world/` for a complete multi-platform plugin example:

- Cross-platform skills
- Claude Code-specific agents
- Cursor-specific rules
- Shared hooks and MCP configuration

## Limitations & Constraints

### Platform-Specific Gaps

**Codex:**
- No agent support (use skills instead)
- No hook support
- Skills are required field

**Cursor:**
- No LSP support (Claude Code feature)

**Claude Code:**
- All features supported

### Component Reuse

| Component | Claude → Cursor | Claude → Codex | Cursor → Claude |
|-----------|-----------------|----------------|-----------------|
| Skills | ✅ Direct | ✅ Direct | ✅ Direct |
| Agents | ✅ Mostly | ⚠️ Rewrite | ✅ Mostly |
| Hooks | ✅ Mostly | ❌ Not supported | ✅ Mostly |
| MCP | ✅ Direct | ✅ Direct | ✅ Direct |
| LSP | ❌ N/A | ❌ N/A | ❌ N/A |

## Best Practices

1. **Keep components platform-agnostic** when possible
2. **Use `plugin-config.json`** as single source of truth
3. **Test on all platforms** before release
4. **Document platform-specific behaviors** in component READMEs
5. **Version manifests** consistently across platforms
6. **Use conditional logic** in hooks/agents for platform differences

## Troubleshooting

**Q: My Cursor plugin isn't installing**
A: Verify `.cursor-plugin/plugin.json` exists and `name` field is in kebab-case.

**Q: Skills work on Claude Code but not Codex**
A: Check that Codex plugin manifest includes `"skills": "./skills/"` field.

**Q: Generated manifests are missing fields**
A: Verify `plugin-config.json` is valid and `generate-manifests.sh` ran successfully.

## Resources

- [Claude Code Plugins](https://code.claude.com/docs/en/plugins-reference)
- [Cursor Plugins](https://cursor.com/docs/plugins)
- [Codex Plugins](https://developers.openai.com/codex/plugins/build)
