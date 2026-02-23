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
if ! ARTIFACT_PATH=$("${SCRIPT_DIR}/build-plugin.sh" "${PLUGIN_DIR}" 2>&1 | tail -1); then
	echo "ERROR: Failed to build plugin artifact"
	exit 1
fi

if [[ ! -f "${ARTIFACT_PATH}" ]]; then
	echo "ERROR: Plugin artifact not created at ${ARTIFACT_PATH}"
	exit 1
fi

echo "Plugin artifact created: ${ARTIFACT_PATH}"

# Step 2: Extract artifact to temporary directory
echo "Step 2: Extracting plugin artifact..."
TEMP_PLUGINS_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_PLUGINS_DIR}" EXIT

if ! tar -xzf "${ARTIFACT_PATH}" -C "${TEMP_PLUGINS_DIR}"; then
	echo "ERROR: Failed to extract plugin artifact"
	exit 1
fi

EXTRACTED_PLUGIN_DIR="${TEMP_PLUGINS_DIR}/${PLUGIN_NAME}"

# Step 3: Verify the artifact structure
echo "Step 3: Verifying artifact structure..."
if [[ ! -d "${EXTRACTED_PLUGIN_DIR}" ]]; then
	echo "ERROR: Plugin directory not found in extracted artifact"
	ls -la "${TEMP_PLUGINS_DIR}"
	exit 1
fi

if [[ ! -f "${EXTRACTED_PLUGIN_DIR}/.claude-plugin/plugin.json" ]]; then
	echo "ERROR: Plugin manifest not found in extracted artifact"
	exit 1
fi

echo "Artifact structure verified"

# Step 4: Test plugin loads from extracted location with --plugin-dir
echo "Step 4: Testing plugin loading via --plugin-dir..."
if ! claude --plugin-dir "${EXTRACTED_PLUGIN_DIR}" --help >/dev/null 2>&1; then
	echo "ERROR: Plugin failed to load from extracted artifact"
	claude --plugin-dir "${EXTRACTED_PLUGIN_DIR}" --help || true
	exit 1
fi

echo "Plugin loads successfully from artifact"

# Step 5: Validate plugin configuration
echo "Step 5: Validating plugin configuration..."
if ! claude plugin validate "${EXTRACTED_PLUGIN_DIR}" >/dev/null 2>&1; then
	echo "ERROR: Plugin validation failed"
	claude plugin validate "${EXTRACTED_PLUGIN_DIR}" || true
	exit 1
fi

echo "Plugin validation passed"

echo ""
echo "All plugin installation tests passed for: ${PLUGIN_NAME}"
