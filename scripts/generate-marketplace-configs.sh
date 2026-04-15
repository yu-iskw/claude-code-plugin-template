#!/usr/bin/env bash
# Generate platform-specific marketplace configurations from a unified plugin-config.json
# Usage: ./scripts/generate-marketplace-configs.sh [--platform claude|cursor|codex] [--plugin-dir PLUGIN_DIR]

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

Generate platform-specific marketplace configurations for plugins.

OPTIONS:
  --platform PLATFORM    Generate only for specific platform (claude|cursor|codex)
  --plugin-dir DIR       Plugin directory to process (default: all in plugins/)
  --help                 Show this help message

EXAMPLES:
  # Generate marketplace configs for all plugins
  ./scripts/generate-marketplace-configs.sh

  # Generate only Cursor marketplace config
  ./scripts/generate-marketplace-configs.sh --platform cursor

  # Process specific plugin
  ./scripts/generate-marketplace-configs.sh --plugin-dir plugins/my-plugin

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

  log_info "Processing marketplace configs for: $plugin_name"

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

  # Generate Claude Code marketplace config
  if [[ -z "$PLATFORM" ]] || [[ "$PLATFORM" == "claude" ]]; then
    if jq -e '.platforms.claude.enabled // false' "$config_file" > /dev/null; then
      CLAUDE_MARKET_DIR="$plugin_dir/.claude-plugin"
      mkdir -p "$CLAUDE_MARKET_DIR"

      # Extract marketplace metadata
      MARKETPLACE=$(jq -r '.marketplace.claude // {}' "$config_file")

      CLAUDE_MARKET=$(jq -n \
        --arg name "$NAME" \
        --arg version "$VERSION" \
        --arg desc "$DESCRIPTION" \
        --argjson author "$AUTHOR" \
        --arg license "$LICENSE" \
        --arg repo "$REPOSITORY" \
        --argjson market "$MARKETPLACE" \
        '{
          name: $name,
          version: $version,
          description: $desc,
          author: $author,
          license: $license,
          repository: $repo
        } + ($market | if type == "object" then . else {} end)')

      echo "$CLAUDE_MARKET" | jq '.' > "$CLAUDE_MARKET_DIR/marketplace.json"
      log_success "Generated Claude Code marketplace config"
    fi
  fi

  # Generate Cursor marketplace config
  if [[ -z "$PLATFORM" ]] || [[ "$PLATFORM" == "cursor" ]]; then
    if jq -e '.platforms.cursor.enabled // false' "$config_file" > /dev/null; then
      CURSOR_MARKET_DIR="$plugin_dir/.cursor-plugin"
      mkdir -p "$CURSOR_MARKET_DIR"

      # Extract marketplace metadata
      MARKETPLACE=$(jq -r '.marketplace.cursor // {}' "$config_file")

      CURSOR_MARKET=$(jq -n \
        --arg name "$NAME" \
        --arg version "$VERSION" \
        --arg desc "$DESCRIPTION" \
        --argjson author "$AUTHOR" \
        --argjson market "$MARKETPLACE" \
        '{
          name: $name,
          version: $version,
          description: $desc,
          author: $author
        } + ($market | if type == "object" then . else {} end)')

      # Add optional fields
      if [[ -n "$LICENSE" ]] && [[ "$LICENSE" != "null" ]]; then
        CURSOR_MARKET=$(echo "$CURSOR_MARKET" | jq --arg license "$LICENSE" '. + {license: $license}')
      fi

      if [[ -n "$REPOSITORY" ]] && [[ "$REPOSITORY" != "null" ]]; then
        CURSOR_MARKET=$(echo "$CURSOR_MARKET" | jq --arg repo "$REPOSITORY" '. + {repository: $repo}')
      fi

      echo "$CURSOR_MARKET" | jq '.' > "$CURSOR_MARKET_DIR/marketplace.json"
      log_success "Generated Cursor marketplace config"
    fi
  fi

  # Generate Codex marketplace config
  if [[ -z "$PLATFORM" ]] || [[ "$PLATFORM" == "codex" ]]; then
    if jq -e '.platforms.codex.enabled // false' "$config_file" > /dev/null; then
      CODEX_MARKET_DIR="$plugin_dir/.codex-plugin"
      mkdir -p "$CODEX_MARKET_DIR"

      # Extract marketplace metadata
      MARKETPLACE=$(jq -r '.marketplace.codex // {}' "$config_file")

      CODEX_MARKET=$(jq -n \
        --arg name "$NAME" \
        --arg version "$VERSION" \
        --arg desc "$DESCRIPTION" \
        --argjson market "$MARKETPLACE" \
        '{
          name: $name,
          version: $version,
          description: $desc
        } + ($market | if type == "object" then . else {} end)')

      # Add optional fields
      if [[ -n "$LICENSE" ]] && [[ "$LICENSE" != "null" ]]; then
        CODEX_MARKET=$(echo "$CODEX_MARKET" | jq --arg license "$LICENSE" '. + {license: $license}')
      fi

      if [[ -n "$REPOSITORY" ]] && [[ "$REPOSITORY" != "null" ]]; then
        CODEX_MARKET=$(echo "$CODEX_MARKET" | jq --arg repo "$REPOSITORY" '. + {repository: $repo}')
      fi

      echo "$CODEX_MARKET" | jq '.' > "$CODEX_MARKET_DIR/marketplace.json"
      log_success "Generated Codex marketplace config"
    fi
  fi

done

log_success "Marketplace configuration generation complete!"
