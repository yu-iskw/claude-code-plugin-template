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

# Build and install all plugins in the Docker container
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${SCRIPT_DIR}/.." || exit 1

# Check if Claude CLI is available
if ! command -v claude >/dev/null 2>&1; then
	echo "WARNING: Claude CLI not found. Skipping plugin installation."
	exit 0
fi

echo "Building and installing plugins..."

# Discover plugins
PLUGINS=()
if [[ -d "plugins" ]]; then
	for d in plugins/*/; do
		if [[ -d "${d}.claude-plugin" ]]; then
			PLUGINS+=("${d%/}")
		fi
	done
fi

# Fallback to root if no plugins found in plugins/ (for backward compatibility)
if [[ ${#PLUGINS[@]} -eq 0 ]]; then
	if [[ -d ".claude-plugin" ]]; then
		PLUGINS+=(".")
	fi
fi

if [[ ${#PLUGINS[@]} -eq 0 ]]; then
	echo "No plugins found to build and install."
	exit 0
fi

FAILED_INSTALLS=0

for plugin in "${PLUGINS[@]}"; do
	echo ""
	echo ">>> Building plugin: ${plugin}"

	# Build plugin artifact
	echo "Building plugin artifact..."
	ARTIFACT_PATH=$("${SCRIPT_DIR}/build-plugin.sh" "${plugin}" 2>&1 | tail -1)

	if [[ -z "${ARTIFACT_PATH}" ]]; then
		echo "ERROR: Failed to get artifact path for plugin: ${plugin}"
		FAILED_INSTALLS=$((FAILED_INSTALLS + 1))
		continue
	fi

	if [[ ! -f "${ARTIFACT_PATH}" ]]; then
		echo "ERROR: Plugin artifact not created for: ${plugin}"
		FAILED_INSTALLS=$((FAILED_INSTALLS + 1))
		continue
	fi

	# Verify artifact can be extracted
	echo "Verifying artifact structure..."
	TEMP_DIR=$(mktemp -d)
	if ! tar -xzf "${ARTIFACT_PATH}" -C "${TEMP_DIR}"; then
		echo "ERROR: Failed to extract plugin artifact for: ${plugin}"
		rm -rf "${TEMP_DIR}"
		FAILED_INSTALLS=$((FAILED_INSTALLS + 1))
		continue
	fi

	# Verify manifest exists in artifact
	# Extract plugin name from path (e.g., "plugins/hello-world" -> "hello-world")
	PLUGIN_NAME="${plugin##*/}"
	if [[ ! -f "${TEMP_DIR}/${PLUGIN_NAME}/.claude-plugin/plugin.json" ]]; then
		echo "ERROR: Plugin manifest not found in artifact for: ${plugin}"
		rm -rf "${TEMP_DIR}"
		FAILED_INSTALLS=$((FAILED_INSTALLS + 1))
		continue
	fi

	rm -rf "${TEMP_DIR}"
	echo "Plugin '${plugin}' artifact verified successfully"
done

echo ""
if [[ ${FAILED_INSTALLS} -gt 0 ]]; then
	echo "ERROR: ${FAILED_INSTALLS} plugin(s) failed to install"
	exit 1
else
	echo "All plugins built and installed successfully!"
	exit 0
fi
