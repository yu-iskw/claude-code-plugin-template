---
name: lint-fix
description: Install trunk (if needed) and run formatting and linting checks.
---

# Lint Fix

Run formatting and lint checks using trunk. This skill automatically handles trunk installation based on your platform.

## Workflow

1. **Detect platform and trunk availability**
   - Check if trunk is already installed
   - Detect OS (macOS vs Linux/other)
   - In CI/remote environments, skip installation prompts

2. **Install trunk (if needed)**
   - On macOS: Use Homebrew (`brew install trunk-io/trunk/trunk`)
   - On Linux: Use official installer (`curl https://get.trunk.io -fsSL | bash`)
   - On local machines: Ask user permission before installing

3. **Run linting operations**
   - Run `trunk fmt --all` to format code
   - Run `trunk check --all -y` to check for violations
   - Report any failures and guidance

4. **Handle failures**
   - Display violations and their locations
   - Provide guidance for fixing common issues

## Usage

When you need to format and lint your code:

```bash
# Using the skill through Claude Code
# This automatically handles platform detection and trunk installation
```

## How It Works

The skill:
- Detects your platform automatically (macOS, Linux, etc.)
- Checks if trunk is already installed
- For local machines: Asks for permission before installing trunk
- For CI/remote environments: Auto-detects and uses available tools
- Runs both formatting and linting checks
- Reports results clearly

## Installation Methods

### macOS with Homebrew
```bash
brew install trunk-io/trunk/trunk
```

### Linux and Other Platforms
```bash
curl https://get.trunk.io -fsSL | bash
```

This script automates trunk installation - on local machines it asks for permission, in CI it uses available tools automatically.

## Configuration

The project uses trunk with these linters:
- **shellcheck**: Shell script validation
- **yamllint**: YAML file validation
- **markdownlint**: Markdown validation
- **hadolint**: Dockerfile validation

See `.trunk/trunk.yaml` for complete configuration.

## Progressive Disclosure

- **Trunk documentation**: [Getting Started](https://docs.trunk.io/check/getting-started)
- **Installation guide**: [https://github.com/trunk-io/docs/blob/main/code-quality/overview/cli/getting-started/install.md](https://github.com/trunk-io/docs/blob/main/code-quality/overview/cli/getting-started/install.md)
- **Makefile targets**: [Makefile](../../../Makefile) at repo root
- **Trunk config**: [.trunk/trunk.yaml](../../../.trunk/trunk.yaml)

## Related Skills

- Plugin verification: `../plugin-verification/SKILL.md`
- Agent skills implementation: `../implement-agent-skills/SKILL.md`

## Sources

- https://docs.trunk.io/check
- https://docs.trunk.io/code-quality/linters/run-linters
- https://github.com/trunk-io/docs/blob/main/code-quality/overview/cli/getting-started/install.md

