# Claude Code Configuration

This file configures Claude Code's behavior for this project.

## Project Overview

This is a Claude Code plugin template for building and testing Claude plugins with automated quality checks.

## Automatic Code Quality Requirements

**Every coding task MUST include these checks before completion:**

1. **Run Integration Tests**
   ```bash
   ./integration_tests/run.sh --verbose
   ```
   - All 4 tests must pass
   - Do not proceed if tests fail

2. **Run Linting Checks**
   ```bash
   ./lint-fix.sh
   ```
   - Must fix ALL linting errors (not just warnings)
   - Use shellcheck, yamllint, and other configured linters
   - All shell scripts must be syntactically valid

3. **Shell Script Validation**
   ```bash
   bash -n <script.sh>  # For each shell script modified
   ```
   - Every shell script must pass syntax validation

4. **Commit with Clear Messages**
   - Include the session URL: `https://claude.ai/code/session_<SESSION_ID>`
   - Describe what was fixed and why
   - Never commit broken code

## Key Files and Responsibilities

### Shell Scripts
- `integration_tests/run.sh` - Main test runner
- `integration_tests/build-plugin.sh` - Plugin artifact builder
- `integration_tests/test-plugin-install.sh` - Plugin installation tester
- `integration_tests/build-and-install-plugins.sh` - Batch plugin builder
- `.claude/skills/lint-fix/lint-fix.sh` - Linting executor

**Critical Requirements for Shell Scripts:**
- Use proper variable quoting: `"${VAR}"` not `${VAR}`
- Use proper trap commands: `trap 'rm -rf "${DIR}"' EXIT` (not unquoted)
- Use `set -euo pipefail` for error handling
- Validate all commands with `bash -n`
- No word splitting or glob expansion issues

### YAML Files
- `.github/workflows/integration_tests.yml` - Integration test workflow
- `.github/workflows/trunk_check.yml` - Linting workflow
- `.github/workflows/trunk_upgrade.yml` - Trunk upgrade workflow
- `.trunk/trunk.yaml` - Linter configuration

**Critical Requirements for YAML:**
- All files must start with `---` (document start marker)
- Comments need 2 spaces before them: `key: value  # comment`
- No line longer than 80 characters
- Proper permissions configuration at workflow level
- Cannot use `permissions: read-all` - must specify `contents: read`

### Plugin Testing
- `.claude-plugin/plugin.json` - Plugin manifest
- `plugins/` - Directory containing plugins to test

**Critical Requirements for Plugins:**
- Manifest must be valid JSON
- Plugin artifacts must include hidden files (e.g., `.claude-plugin/`)
- Artifacts are extracted to plugin name only (not `plugins/plugin-name/`)

## Trunk Configuration

Trunk is installed and configured in `.trunk/trunk.yaml`:
- **Linters enabled**: shellcheck, yamllint, actionlint, markdownlint, prettier
- **Configuration**: `.trunk/configs/` contains linter-specific configs
- **Installation**:
  - macOS: `brew install trunk-io/trunk/trunk`
  - Linux: `curl https://get.trunk.io -fsSL | bash`
  - CI: trunk-io/trunk-action GitHub Action

## Common Mistakes to AVOID

### ❌ MISTAKE 1: Unquoted variables in trap commands
```bash
# WRONG - Will fail with spaces in paths
trap "rm -rf ${DIR}" EXIT

# RIGHT - Properly quoted
trap 'rm -rf "${DIR}"' EXIT
```

### ❌ MISTAKE 2: Poor error checking in pipelines
```bash
# WRONG - Pipeline errors hidden
ARTIFACT_PATH=$("${SCRIPT_DIR}/build.sh" 2>&1 | tail -1)

# RIGHT - Proper error checking
ARTIFACT_PATH=$("${SCRIPT_DIR}/build.sh" 2>&1 | tail -1)
if [[ -z "${ARTIFACT_PATH}" ]]; then exit 1; fi
```

### ❌ MISTAKE 3: Plugin path confusion
```bash
# WRONG - Using full path in archive check
if [[ ! -f "${TEMP_DIR}/${plugin}/.claude-plugin/plugin.json" ]]; then

# RIGHT - Extract just the plugin name
PLUGIN_NAME="${plugin##*/}"
if [[ ! -f "${TEMP_DIR}/${PLUGIN_NAME}/.claude-plugin/plugin.json" ]]; then
```

### ❌ MISTAKE 4: Missing YAML document start
```yaml
# WRONG
name: My Workflow
on:
  push:

# RIGHT
---
name: My Workflow
on:
  push:
```

### ❌ MISTAKE 5: Conflicting workflow permissions
```yaml
# WRONG - Conflicts with job-level write permissions
permissions: read-all
jobs:
  my-job:
    permissions:
      contents: write

# RIGHT - Allows job-level overrides
permissions:
  contents: read
jobs:
  my-job:
    permissions:
      contents: write
```

## Self-Improvement Protocol for Agents

When working on this project, autonomous agents MUST:

1. **Before making changes:**
   - Run full test suite: `./integration_tests/run.sh --verbose`
   - Check current linting status

2. **While making changes:**
   - Validate shell scripts with `bash -n`
   - Validate YAML with `yamllint`
   - Use proper quoting and error handling patterns

3. **After making changes:**
   - Run full test suite again
   - Run linting checks: `./lint-fix.sh` (fix ALL errors)
   - Verify no test regressions
   - Check git status and staged changes
   - Commit with clear, descriptive messages
   - Push to the designated feature branch

4. **If tests fail:**
   - Stop immediately
   - Investigate root cause
   - Do NOT proceed until all tests pass
   - Do NOT commit broken code

## Testing Strategy

### Unit Tests
- Plugin manifest validation: `validate-manifest.sh`
- Plugin loading: `test-plugin-loading.sh`
- Plugin installation: `test-plugin-install.sh`

### Integration Tests
- Full workflow: `./integration_tests/run.sh --verbose`
- Docker integration: `make test-integration-docker`

### Linting
- Shell scripts: shellcheck with `-x` flag
- YAML: yamllint with `.trunk/configs/.yamllint.yaml`
- GitHub Actions: actionlint

## Branch Protection Rules

**Feature Branch:** `claude/test-docker-plugin-install-26yZx`
- All commits must pass:
  - Shell syntax validation
  - YAML validation
  - Integration tests (all 4 must pass)
  - Linting checks (no errors)
- Push with: `git push -u origin <branch-name>`

## Success Criteria

A task is complete when:

✅ All integration tests pass (4/4)
✅ All shell scripts are syntactically valid
✅ All YAML files are valid and properly formatted
✅ All linting errors are fixed (warnings acceptable if documented)
✅ No test regressions
✅ Clear commit messages with session URL
✅ Code is pushed to feature branch

## Session Information

This project is being developed in Claude Code sessions.
Always include the session URL in commit messages for traceability.

Format: `https://claude.ai/code/session_<SESSION_ID>`

This enables:
- Code review and audit trails
- Automatic linking between commits and sessions
- Quality tracking over time
- Agent learning from previous sessions
