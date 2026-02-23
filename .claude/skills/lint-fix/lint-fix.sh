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

# Lint and format script with smart trunk installation
set -euo pipefail

# Detect platform
PLATFORM="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
	PLATFORM="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
	PLATFORM="linux"
else
	PLATFORM="other"
fi

# Check if running in CI environment
IS_CI=false
if [[ -n "${CI:-}" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]] || [[ -n "${GITLAB_CI:-}" ]] || [[ -n "${CIRCLECI:-}" ]]; then
	IS_CI=true
fi

# Check if trunk is available
trunk_available() {
	command -v trunk >/dev/null 2>&1
}

# Install trunk based on platform
install_trunk() {
	if trunk_available; then
		echo "✓ trunk is already installed"
		return 0
	fi

	echo "trunk is not installed. Setting up..."

	if [[ "${IS_CI}" == true ]]; then
		# In CI environment, use npx
		echo "ℹ CI environment detected, using npx for trunk"
		return 0
	fi

	# On local machine, ask for permission
	if [[ "${PLATFORM}" == "macos" ]]; then
		echo ""
		echo "Install trunk using Homebrew?"
		echo "  brew install trunk-io/trunk/trunk"
		echo ""
		read -p "Install trunk? (y/n) " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			brew install trunk-io/trunk/trunk || {
				echo "ERROR: Failed to install trunk with homebrew"
				return 1
			}
		else
			echo "ℹ Skipping installation, will use alternative method"
			return 0
		fi
	else
		echo ""
		echo "Install trunk?"
		echo "  curl https://get.trunk.io -fsSL | bash"
		echo ""
		read -p "Install trunk? (y/n) " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			curl https://get.trunk.io -fsSL | bash || {
				echo "ERROR: Failed to install trunk"
				return 1
			}
			# Add trunk to PATH if it was just installed
			export PATH="$HOME/.local/share/trunk/bin:$PATH"
		else
			echo "ℹ Skipping installation"
			return 0
		fi
	fi
}

# Run trunk command (use npx if trunk not available)
run_trunk() {
	if trunk_available; then
		trunk "$@"
	else
		echo "ℹ Using npx to run trunk (not installed locally)"
		npx trunk "$@"
	fi
}

# Main execution
echo "=== Starting lint and format checks ==="
echo "Platform: ${PLATFORM}"
echo "CI Environment: ${IS_CI}"
echo ""

# Try to install trunk if needed
install_trunk

echo ""
echo "Step 1: Formatting code..."
if run_trunk fmt --all; then
	echo "✓ Code formatted successfully"
else
	echo "⚠ Code formatting completed with warnings"
fi

echo ""
echo "Step 2: Checking for violations..."
if run_trunk check --all -y; then
	echo "✓ All checks passed!"
	exit 0
else
	echo "✗ Some checks failed. See above for details."
	exit 1
fi
