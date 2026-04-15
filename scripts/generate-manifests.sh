#!/usr/bin/env bash
# Generate platform-specific plugin manifests from a unified plugin-config.json
# Usage: ./scripts/generate-manifests.sh [--platform claude|cursor|codex] [--plugin-dir PLUGIN_DIR]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
PLATFORM=""
PLUGIN_DIR=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_error() {
  printf '%b\n' "${RED}✗ Error: $1${NC}" >&2
}

log_success() {
  printf '%b\n' "${GREEN}✓ $1${NC}"
}

log_info() {
  printf '%b\n' "${YELLOW}ℹ $1${NC}"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Generate platform-specific manifests for plugins.

OPTIONS:
  --platform PLATFORM    Generate only for specific platform (claude|cursor|codex)
  --plugin-dir DIR       Plugin directory to process (default: all in plugins/)
  --help                 Show this help message

EXAMPLES:
  # Generate all manifests for all plugins
  ./scripts/generate-manifests.sh

  # Generate only Cursor manifests
  ./scripts/generate-manifests.sh --platform cursor

  # Process specific plugin
  ./scripts/generate-manifests.sh --plugin-dir plugins/my-plugin

EOF
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)
      PLATFORM="$2"
      shift 2
      ;;
    --plugin-dir)
      PLUGIN_DIR="$2"
      shift 2
      ;;
    --help)
      usage
      ;;
    *)
      log_error "Unknown option: $1"
      usage
      ;;
  esac
done

# Validate platform if specified
if [[ -n "$PLATFORM" ]]; then
  if ! [[ "$PLATFORM" =~ ^(claude|cursor|codex)$ ]]; then
    log_error "Invalid platform: $PLATFORM (must be claude, cursor, or codex)"
    exit 1
  fi
fi

# Require jq
if ! command -v jq &> /dev/null; then
  log_error "jq is required but not installed"
  exit 1
fi

# Find plugin directories
if [[ -n "$PLUGIN_DIR" ]]; then
  if [[ ! -d "$PLUGIN_DIR" ]]; then
    log_error "Plugin directory not found: $PLUGIN_DIR"
    exit 1
  fi
  PLUGINS=("$PLUGIN_DIR")
else
  PLUGINS=()
  while IFS= read -r -d '' dir; do
    PLUGINS+=("$dir")
  done < <(find "$REPO_ROOT/plugins" -maxdepth 1 -type d -mindepth 1 -print0)
fi

if [[ ${#PLUGINS[@]} -eq 0 ]]; then
  log_error "No plugins found"
  exit 1
fi

# Process each plugin
for plugin_dir in "${PLUGINS[@]}"; do
  plugin_name="$(basename "$plugin_dir")"
  config_file="$plugin_dir/plugin-config.json"

  if [[ ! -f "$config_file" ]]; then
    log_info "Skipping $plugin_name (no plugin-config.json)"
    continue
  fi

  log_info "Processing plugin: $plugin_name"

  # Validate JSON
  if ! jq empty "$config_file" 2>/dev/null; then
    log_error "$plugin_name: Invalid JSON in plugin-config.json"
    continue
  fi

  # Extract base metadata
  NAME=$(jq -r '.name' "$config_file")
  VERSION=$(jq -r '.version // "1.0.0"' "$config_file")
  DESCRIPTION=$(jq -r '.description // ""' "$config_file")
  AUTHOR=$(jq -r '.author // {}' "$config_file")
  LICENSE=$(jq -r '.license // ""' "$config_file")
  REPOSITORY=$(jq -r '.repository // ""' "$config_file")
  HOMEPAGE=$(jq -r '.homepage // ""' "$config_file")

  # Generate Claude Code manifest
  if [[ -z "$PLATFORM" ]] || [[ "$PLATFORM" == "claude" ]]; then
    if jq -e '.platforms.claude.enabled // false' "$config_file" > /dev/null; then
      CLAUDE_MANIFEST_DIR="$plugin_dir/.claude-plugin"
      mkdir -p "$CLAUDE_MANIFEST_DIR"

      MCP_SERVERS=$(jq -r '.platforms.claude.mcpServers // ""' "$config_file")
      LSP_SERVERS=$(jq -r '.platforms.claude.lspServers // ""' "$config_file")

      CLAUDE_MANIFEST=$(jq -n \
        --arg name "$NAME" \
        --arg version "$VERSION" \
        --arg desc "$DESCRIPTION" \
        --argjson author "$AUTHOR" \
        --arg license "$LICENSE" \
        --arg repo "$REPOSITORY" \
        '{
          name: $name,
          version: $version,
          description: $desc,
          author: $author,
          license: $license,
          repository: $repo
        }')

      # Add optional MCP/LSP fields
      if [[ -n "$MCP_SERVERS" ]] && [[ "$MCP_SERVERS" != "null" ]]; then
        CLAUDE_MANIFEST=$(echo "$CLAUDE_MANIFEST" | jq --arg mcp "$MCP_SERVERS" '. + {mcpServers: $mcp}')
      fi

      if [[ -n "$LSP_SERVERS" ]] && [[ "$LSP_SERVERS" != "null" ]]; then
        CLAUDE_MANIFEST=$(echo "$CLAUDE_MANIFEST" | jq --arg lsp "$LSP_SERVERS" '. + {lspServers: $lsp}')
      fi

      echo "$CLAUDE_MANIFEST" | jq '.' > "$CLAUDE_MANIFEST_DIR/plugin.json"
      log_success "Generated Claude Code manifest: .claude-plugin/plugin.json"
    fi
  fi

  # Generate Cursor manifest
  if [[ -z "$PLATFORM" ]] || [[ "$PLATFORM" == "cursor" ]]; then
    if jq -e '.platforms.cursor.enabled // false' "$config_file" > /dev/null; then
      CURSOR_MANIFEST_DIR="$plugin_dir/.cursor-plugin"
      mkdir -p "$CURSOR_MANIFEST_DIR"

      CURSOR_MANIFEST=$(jq -n \
        --arg name "$NAME" \
        --arg version "$VERSION" \
        --arg desc "$DESCRIPTION" \
        --argjson author "$AUTHOR" \
        '{
          name: $name,
          version: $version,
          description: $desc,
          author: $author
        }')

      # Add optional fields
      if [[ -n "$LICENSE" ]] && [[ "$LICENSE" != "null" ]]; then
        CURSOR_MANIFEST=$(echo "$CURSOR_MANIFEST" | jq --arg license "$LICENSE" '. + {license: $license}')
      fi

      if [[ -n "$REPOSITORY" ]] && [[ "$REPOSITORY" != "null" ]]; then
        CURSOR_MANIFEST=$(echo "$CURSOR_MANIFEST" | jq --arg repo "$REPOSITORY" '. + {repository: $repo}')
      fi

      if [[ -n "$HOMEPAGE" ]] && [[ "$HOMEPAGE" != "null" ]]; then
        CURSOR_MANIFEST=$(echo "$CURSOR_MANIFEST" | jq --arg home "$HOMEPAGE" '. + {homepage: $home}')
      fi

      echo "$CURSOR_MANIFEST" | jq '.' > "$CURSOR_MANIFEST_DIR/plugin.json"
      log_success "Generated Cursor manifest: .cursor-plugin/plugin.json"
    fi
  fi

  # Generate Codex manifest
  if [[ -z "$PLATFORM" ]] || [[ "$PLATFORM" == "codex" ]]; then
    if jq -e '.platforms.codex.enabled // false' "$config_file" > /dev/null; then
      CODEX_MANIFEST_DIR="$plugin_dir/.codex-plugin"
      mkdir -p "$CODEX_MANIFEST_DIR"

      SKILLS=$(jq -r '.platforms.codex.skills // "./skills/"' "$config_file")

      CODEX_MANIFEST=$(jq -n \
        --arg name "$NAME" \
        --arg version "$VERSION" \
        --arg desc "$DESCRIPTION" \
        --arg skills "$SKILLS" \
        '{
          name: $name,
          version: $version,
          description: $desc,
          skills: $skills
        }')

      # Add optional fields
      if [[ -n "$LICENSE" ]] && [[ "$LICENSE" != "null" ]]; then
        CODEX_MANIFEST=$(echo "$CODEX_MANIFEST" | jq --arg license "$LICENSE" '. + {license: $license}')
      fi

      if [[ -n "$REPOSITORY" ]] && [[ "$REPOSITORY" != "null" ]]; then
        CODEX_MANIFEST=$(echo "$CODEX_MANIFEST" | jq --arg repo "$REPOSITORY" '. + {repository: $repo}')
      fi

      if [[ -n "$HOMEPAGE" ]] && [[ "$HOMEPAGE" != "null" ]]; then
        CODEX_MANIFEST=$(echo "$CODEX_MANIFEST" | jq --arg home "$HOMEPAGE" '. + {homepage: $home}')
      fi

      echo "$CODEX_MANIFEST" | jq '.' > "$CODEX_MANIFEST_DIR/plugin.json"
      log_success "Generated Codex manifest: .codex-plugin/plugin.json"
    fi
  fi

done

log_success "Manifest generation complete!"
