#!/usr/bin/env bash
# Validate platform-specific plugin manifests
# Usage: ./scripts/validate-manifests.sh [--platform claude|cursor|codex] [--plugin-dir PLUGIN_DIR]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
PLATFORM=""
PLUGIN_DIR=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_error() {
  echo -e "${RED}✗ Error: $1${NC}" >&2
}

log_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠ Warning: $1${NC}"
}

log_info() {
  echo -e "${BLUE}ℹ $1${NC}"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Validate platform-specific manifests for plugins.

OPTIONS:
  --platform PLATFORM    Validate only specific platform (claude|cursor|codex)
  --plugin-dir DIR       Plugin directory to validate
  --help                 Show this help message

EXAMPLES:
  # Validate all manifests
  ./scripts/validate-manifests.sh

  # Validate only Cursor manifests
  ./scripts/validate-manifests.sh --platform cursor

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

TOTAL_VALIDATED=0
TOTAL_FAILED=0

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

# Validate Claude Code manifest
validate_claude_manifest() {
  local manifest_file="$1"
  local plugin_dir="$2"
  local has_error=0

  if [[ ! -f "$manifest_file" ]]; then
    log_warning "Claude Code manifest not found: $manifest_file"
    return 0
  fi

  # Validate JSON
  if ! jq empty "$manifest_file" 2>/dev/null; then
    log_error "Invalid JSON in Claude Code manifest: $manifest_file"
    return 1
  fi

  # Check required fields
  for field in name version description author; do
    if ! jq -e ".$field" "$manifest_file" > /dev/null; then
      log_error "Missing required field '$field' in Claude Code manifest"
      has_error=1
    fi
  done

  # Validate mcpServers and lspServers paths if present
  if jq -e '.mcpServers' "$manifest_file" > /dev/null; then
    mcp_path=$(jq -r '.mcpServers' "$manifest_file")
    if [[ ! -f "$plugin_dir/$mcp_path" ]]; then
      log_warning "mcpServers file not found: $plugin_dir/$mcp_path"
    fi
  fi

  if jq -e '.lspServers' "$manifest_file" > /dev/null; then
    lsp_path=$(jq -r '.lspServers' "$manifest_file")
    if [[ ! -f "$plugin_dir/$lsp_path" ]]; then
      log_warning "lspServers file not found: $plugin_dir/$lsp_path"
    fi
  fi

  if [[ $has_error -eq 0 ]]; then
    log_success "Claude Code manifest valid"
    return 0
  else
    return 1
  fi
}

# Validate Cursor manifest
validate_cursor_manifest() {
  local manifest_file="$1"
  local plugin_dir="$2"
  local has_error=0

  if [[ ! -f "$manifest_file" ]]; then
    log_warning "Cursor manifest not found: $manifest_file"
    return 0
  fi

  # Validate JSON
  if ! jq empty "$manifest_file" 2>/dev/null; then
    log_error "Invalid JSON in Cursor manifest: $manifest_file"
    return 1
  fi

  # Check required fields
  for field in name version description author; do
    if ! jq -e ".$field" "$manifest_file" > /dev/null; then
      log_error "Missing required field '$field' in Cursor manifest"
      has_error=1
    fi
  done

  # Validate name is kebab-case
  name=$(jq -r '.name' "$manifest_file")
  if ! [[ "$name" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
    log_warning "Cursor plugin name should be in kebab-case: $name"
  fi

  if [[ $has_error -eq 0 ]]; then
    log_success "Cursor manifest valid"
    return 0
  else
    return 1
  fi
}

# Validate Codex manifest
validate_codex_manifest() {
  local manifest_file="$1"
  local plugin_dir="$2"
  local has_error=0

  if [[ ! -f "$manifest_file" ]]; then
    log_warning "Codex manifest not found: $manifest_file"
    return 0
  fi

  # Validate JSON
  if ! jq empty "$manifest_file" 2>/dev/null; then
    log_error "Invalid JSON in Codex manifest: $manifest_file"
    return 1
  fi

  # Check required fields
  for field in name version description skills; do
    if ! jq -e ".$field" "$manifest_file" > /dev/null; then
      log_error "Missing required field '$field' in Codex manifest"
      has_error=1
    fi
  done

  # Validate skills path
  skills_path=$(jq -r '.skills' "$manifest_file")
  if [[ ! -d "$plugin_dir/$skills_path" ]]; then
    log_warning "Skills directory not found: $plugin_dir/$skills_path"
  fi

  if [[ $has_error -eq 0 ]]; then
    log_success "Codex manifest valid"
    return 0
  else
    return 1
  fi
}

# Process each plugin
for plugin_dir in "${PLUGINS[@]}"; do
  plugin_name="$(basename "$plugin_dir")"
  echo ""
  log_info "Validating plugin: $plugin_name"

  # Check for config file
  if [[ ! -f "$plugin_dir/plugin-config.json" ]]; then
    log_warning "No plugin-config.json found, skipping validation"
    continue
  fi

  # Validate Claude Code
  if [[ -z "$PLATFORM" ]] || [[ "$PLATFORM" == "claude" ]]; then
    echo "  Claude Code:"
    if validate_claude_manifest "$plugin_dir/.claude-plugin/plugin.json" "$plugin_dir"; then
      ((TOTAL_VALIDATED++)) || true
    else
      ((TOTAL_FAILED++)) || true
    fi
  fi

  # Validate Cursor
  if [[ -z "$PLATFORM" ]] || [[ "$PLATFORM" == "cursor" ]]; then
    echo "  Cursor:"
    if validate_cursor_manifest "$plugin_dir/.cursor-plugin/plugin.json" "$plugin_dir"; then
      ((TOTAL_VALIDATED++)) || true
    else
      ((TOTAL_FAILED++)) || true
    fi
  fi

  # Validate Codex
  if [[ -z "$PLATFORM" ]] || [[ "$PLATFORM" == "codex" ]]; then
    echo "  Codex:"
    if validate_codex_manifest "$plugin_dir/.codex-plugin/plugin.json" "$plugin_dir"; then
      ((TOTAL_VALIDATED++)) || true
    else
      ((TOTAL_FAILED++)) || true
    fi
  fi
done

echo ""
log_info "Validation Summary: $TOTAL_VALIDATED validated, $TOTAL_FAILED failed"

if [[ $TOTAL_FAILED -gt 0 ]]; then
  exit 1
fi

log_success "All manifests are valid!"
