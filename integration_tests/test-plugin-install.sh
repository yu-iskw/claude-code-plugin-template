#!/usr/bin/env bash

# Copyright 2026 yu-iskw
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Test plugin installation and discovery
set -euo pipefail

# Check if Claude CLI is available
if ! command -v claude >/dev/null 2>&1; then
	echo "WARNING: Claude CLI not found. Skipping plugin installation tests."
	echo "Install with: npm install -g @anthropic-ai/claude-code"
	exit 0
fi

# Plugin directory passed as argument
PLUGIN_DIR="${1:-.}"
PLUGIN_DIR="$(cd "${PLUGIN_DIR}" && pwd)"

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

MANIFEST_PATH="${PLUGIN_DIR}/.claude-plugin/plugin.json"

if [[ ! -f "${MANIFEST_PATH}" ]]; then
	echo "ERROR: plugin.json not found at ${MANIFEST_PATH}"
	exit 1
fi

# Get plugin name from manifest
if command -v jq >/dev/null 2>&1; then
	PLUGIN_NAME="$(jq -r '.name' "${MANIFEST_PATH}")"
elif command -v node >/dev/null 2>&1; then
	PLUGIN_NAME="$(node -p "require('${MANIFEST_PATH}').name")"
else
	echo "ERROR: Cannot read manifest. Neither jq nor node is available."
	exit 1
fi

echo "Testing plugin installation for: ${PLUGIN_NAME}"

# Step 1: Build the plugin artifact
echo "Step 1: Building plugin artifact..."
ARTIFACT_PATH=$("${SCRIPT_DIR}/build-plugin.sh" "${PLUGIN_DIR}")

if [[ ! -f "${ARTIFACT_PATH}" ]]; then
	echo "ERROR: Plugin artifact not created at ${ARTIFACT_PATH}"
	exit 1
fi

echo "Plugin artifact created: ${ARTIFACT_PATH}"

# Step 2: Install the plugin
echo "Step 2: Installing plugin..."
if ! claude plugin install "${ARTIFACT_PATH}" 2>&1; then
	echo "ERROR: Failed to install plugin from ${ARTIFACT_PATH}"
	claude plugin install "${ARTIFACT_PATH}" || true
	exit 1
fi

echo "Plugin installed successfully"

# Step 3: Verify the plugin is listed
echo "Step 3: Verifying plugin installation..."
if ! claude plugin list 2>&1 | grep -q "${PLUGIN_NAME}"; then
	echo "ERROR: Plugin '${PLUGIN_NAME}' not found in installed plugins list"
	echo "Installed plugins:"
	claude plugin list || true
	exit 1
fi

echo "Plugin '${PLUGIN_NAME}' is installed and listed"

# Step 4: Test that the plugin loads with Claude CLI
echo "Step 4: Testing plugin loading..."
if ! claude --help >/dev/null 2>&1; then
	echo "ERROR: Claude CLI failed after plugin installation"
	exit 1
fi

echo "Plugin loads successfully with Claude CLI"

# Step 5: Validate plugin configuration
echo "Step 5: Validating plugin configuration..."
if ! claude plugin validate "${PLUGIN_DIR}" >/dev/null 2>&1; then
	echo "ERROR: Plugin validation failed"
	claude plugin validate "${PLUGIN_DIR}" || true
	exit 1
fi

echo "Plugin validation passed"

echo ""
echo "All plugin installation tests passed for: ${PLUGIN_NAME}"
