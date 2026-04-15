#!/usr/bin/env bash
# Validate platform-specific marketplace configurations
# Usage: ./scripts/validate-marketplace-configs.sh [--platform claude|cursor|codex] [--plugin-dir PLUGIN_DIR]

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
  printf '%b\n' "${RED}✗ Error: $1${NC}" >&2
}

log_success() {
  printf '%b\n' "${GREEN}✓ $1${NC}"
}

log_warning() {
  printf '%b\n' "${YELLOW}⚠ Warning: $1${NC}"
}

log_info() {
  printf '%b\n' "${BLUE}ℹ $1${NC}"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Validate platform-specific marketplace configurations for plugins.

OPTIONS:
  --platform PLATFORM    Validate only specific platform (claude|cursor|codex)
  --plugin-dir DIR       Plugin directory to validate
  --help                 Show this help message

EXAMPLES:
  # Validate all marketplace configs
  ./scripts/validate-marketplace-configs.sh

  # Validate only Cursor marketplace configs
  ./scripts/validate-marketplace-configs.sh --platform cursor

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

# Validate Claude Code marketplace config
validate_claude_marketplace() {
  local marketplace_file="$1"
  local plugin_dir="$2"
  local has_error=0

  if [[ ! -f "$marketplace_file" ]]; then
    log_warning "Claude Code marketplace config not found: $marketplace_file"
    return 0
  fi

  # Validate JSON
  if ! jq empty "$marketplace_file" 2>/dev/null; then
    log_error "Invalid JSON in Claude Code marketplace config: $marketplace_file"
    return 1
  fi

  # Check required fields
  for field in name version description; do
    if ! jq -e ".$field" "$marketplace_file" > /dev/null; then
      log_error "Missing required field '$field' in Claude Code marketplace config"
      has_error=1
    fi
  done

  # Validate icon paths if present
  if jq -e '.icons' "$marketplace_file" > /dev/null; then
    if jq -e '.icons.light' "$marketplace_file" > /dev/null; then
      icon_path=$(jq -r '.icons.light' "$marketplace_file")
      if [[ ! -f "$plugin_dir/$icon_path" ]]; then
        log_warning "Light icon not found: $plugin_dir/$icon_path"
      fi
    fi
    if jq -e '.icons.dark' "$marketplace_file" > /dev/null; then
      icon_path=$(jq -r '.icons.dark' "$marketplace_file")
      if [[ ! -f "$plugin_dir/$icon_path" ]]; then
        log_warning "Dark icon not found: $plugin_dir/$icon_path"
      fi
    fi
  fi

  # Validate screenshot paths if present
  if jq -e '.screenshots' "$marketplace_file" > /dev/null 2>&1; then
    local count
    count=$(jq '.screenshots | length' "$marketplace_file" 2>/dev/null || echo "0")
    if [[ "$count" =~ ^[0-9]+$ ]] && [[ $count -gt 0 ]]; then
      for i in $(seq 0 $((count - 1))); do
        screenshot=$(jq -r ".screenshots[$i]" "$marketplace_file")
        if [[ -n "$screenshot" ]] && [[ ! -f "$plugin_dir/$screenshot" ]]; then
          log_warning "Screenshot not found: $plugin_dir/$screenshot"
        fi
      done
    fi
  fi

  if [[ $has_error -eq 0 ]]; then
    log_success "Claude Code marketplace config valid"
    return 0
  else
    return 1
  fi
}

# Validate Cursor marketplace config
validate_cursor_marketplace() {
  local marketplace_file="$1"
  local plugin_dir="$2"
  local has_error=0

  if [[ ! -f "$marketplace_file" ]]; then
    log_warning "Cursor marketplace config not found: $marketplace_file"
    return 0
  fi

  # Validate JSON
  if ! jq empty "$marketplace_file" 2>/dev/null; then
    log_error "Invalid JSON in Cursor marketplace config: $marketplace_file"
    return 1
  fi

  # Check required fields
  for field in name version description; do
    if ! jq -e ".$field" "$marketplace_file" > /dev/null; then
      log_error "Missing required field '$field' in Cursor marketplace config"
      has_error=1
    fi
  done

  # Validate icon paths if present
  if jq -e '.icons' "$marketplace_file" > /dev/null; then
    if jq -e '.icons.light' "$marketplace_file" > /dev/null; then
      icon_path=$(jq -r '.icons.light' "$marketplace_file")
      if [[ ! -f "$plugin_dir/$icon_path" ]]; then
        log_warning "Light icon not found: $plugin_dir/$icon_path"
      fi
    fi
    if jq -e '.icons.dark' "$marketplace_file" > /dev/null; then
      icon_path=$(jq -r '.icons.dark' "$marketplace_file")
      if [[ ! -f "$plugin_dir/$icon_path" ]]; then
        log_warning "Dark icon not found: $plugin_dir/$icon_path"
      fi
    fi
  fi

  if [[ $has_error -eq 0 ]]; then
    log_success "Cursor marketplace config valid"
    return 0
  else
    return 1
  fi
}

# Validate Codex marketplace config
validate_codex_marketplace() {
  local marketplace_file="$1"
  local plugin_dir="$2"
  local has_error=0

  if [[ ! -f "$marketplace_file" ]]; then
    log_warning "Codex marketplace config not found: $marketplace_file"
    return 0
  fi

  # Validate JSON
  if ! jq empty "$marketplace_file" 2>/dev/null; then
    log_error "Invalid JSON in Codex marketplace config: $marketplace_file"
    return 1
  fi

  # Check required fields
  for field in name version description; do
    if ! jq -e ".$field" "$marketplace_file" > /dev/null; then
      log_error "Missing required field '$field' in Codex marketplace config"
      has_error=1
    fi
  done

  # Validate icon paths if present
  if jq -e '.icons' "$marketplace_file" > /dev/null; then
    if jq -e '.icons.default' "$marketplace_file" > /dev/null; then
      icon_path=$(jq -r '.icons.default' "$marketplace_file")
      if [[ ! -f "$plugin_dir/$icon_path" ]]; then
        log_warning "Icon not found: $plugin_dir/$icon_path"
      fi
    fi
  fi

  if [[ $has_error -eq 0 ]]; then
    log_success "Codex marketplace config valid"
    return 0
  else
    return 1
  fi
}

# Process each plugin
for plugin_dir in "${PLUGINS[@]}"; do
  plugin_name="$(basename "$plugin_dir")"
  echo ""
  log_info "Validating marketplace configs for: $plugin_name"

  # Check for config file
  if [[ ! -f "$plugin_dir/plugin-config.json" ]]; then
    log_warning "No plugin-config.json found, skipping validation"
    continue
  fi

  # Validate Claude Code
  if [[ -z "$PLATFORM" ]] || [[ "$PLATFORM" == "claude" ]]; then
    echo "  Claude Code:"
    if validate_claude_marketplace "$plugin_dir/.claude-plugin/marketplace.json" "$plugin_dir"; then
      ((TOTAL_VALIDATED++)) || true
    else
      ((TOTAL_FAILED++)) || true
    fi
  fi

  # Validate Cursor
  if [[ -z "$PLATFORM" ]] || [[ "$PLATFORM" == "cursor" ]]; then
    echo "  Cursor:"
    if validate_cursor_marketplace "$plugin_dir/.cursor-plugin/marketplace.json" "$plugin_dir"; then
      ((TOTAL_VALIDATED++)) || true
    else
      ((TOTAL_FAILED++)) || true
    fi
  fi

  # Validate Codex
  if [[ -z "$PLATFORM" ]] || [[ "$PLATFORM" == "codex" ]]; then
    echo "  Codex:"
    if validate_codex_marketplace "$plugin_dir/.codex-plugin/marketplace.json" "$plugin_dir"; then
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

log_success "All marketplace configs are valid!"
