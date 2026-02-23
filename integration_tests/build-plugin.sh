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

# Build plugin artifact (tarball)
set -euo pipefail

# Plugin directory passed as argument
PLUGIN_DIR="${1:-.}"

# Get absolute path
PLUGIN_DIR="$(cd "${PLUGIN_DIR}" && pwd)"

# Extract plugin name from manifest
MANIFEST_PATH="${PLUGIN_DIR}/.claude-plugin/plugin.json"

if [[ ! -f "${MANIFEST_PATH}" ]]; then
	echo "ERROR: plugin.json not found at ${MANIFEST_PATH}"
	exit 1
fi

# Parse plugin name and version
if command -v jq >/dev/null 2>&1; then
	PLUGIN_NAME="$(jq -r '.name' "${MANIFEST_PATH}")"
	PLUGIN_VERSION="$(jq -r '.version' "${MANIFEST_PATH}")"
elif command -v node >/dev/null 2>&1; then
	PLUGIN_NAME="$(node -p "require('${MANIFEST_PATH}').name")"
	PLUGIN_VERSION="$(node -p "require('${MANIFEST_PATH}').version")"
else
	echo "ERROR: Cannot parse manifest. Neither jq nor node is available."
	exit 1
fi

# Create output directory
OUTPUT_DIR="${PLUGIN_DIR}/dist"
mkdir -p "${OUTPUT_DIR}"

# Create tarball
ARTIFACT_NAME="${PLUGIN_NAME}-${PLUGIN_VERSION}.tar.gz"
ARTIFACT_PATH="${OUTPUT_DIR}/${ARTIFACT_NAME}"

echo "Building plugin artifact for: ${PLUGIN_NAME} (${PLUGIN_VERSION})"
echo "Source: ${PLUGIN_DIR}"
echo "Output: ${ARTIFACT_PATH}"

# Create a temporary directory for building the archive
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "${BUILD_DIR}"' EXIT

# Copy plugin files to build directory (including hidden files)
mkdir -p "${BUILD_DIR}/${PLUGIN_NAME}"
# Copy all files and directories, including hidden ones
shopt -s dotglob
cp -r "${PLUGIN_DIR}"/* "${BUILD_DIR}/${PLUGIN_NAME}/"
shopt -u dotglob
# Remove the dist directory if it was copied (we don't want to include artifacts)
rm -rf "${BUILD_DIR}/${PLUGIN_NAME}/dist" 2>/dev/null || true

# Create tarball from build directory
cd "${BUILD_DIR}" || exit 1
if ! tar -czf "${ARTIFACT_PATH}" "${PLUGIN_NAME}/"; then
	echo "ERROR: Failed to create tar archive"
	exit 1
fi

echo "Plugin artifact created successfully: ${ARTIFACT_PATH}"
echo "${ARTIFACT_PATH}"
