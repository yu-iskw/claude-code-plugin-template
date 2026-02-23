# Autonomous Agent Guidelines

This file defines how autonomous agents should work on this Claude Code plugin template project.

## Agent Self-Improvement Protocol

### Phase 1: Pre-Work Assessment

Before starting ANY coding task:

```bash
# 1. Check current test status
./integration_tests/run.sh --verbose

# 2. Check linting status
bash .claude/skills/lint-fix/lint-fix.sh

# 3. Review recent commits
git log --oneline -10

# 4. Check for uncommitted changes
git status
```

**If any tests fail or linting fails:**
- Investigate and fix BEFORE starting new work
- Do not proceed with new features until code is clean

### Phase 2: Implementation

**FOR EVERY FILE CHANGE:**

1. **Shell Scripts (.sh)**
   - Always use: `set -euo pipefail`
   - Always quote variables: `"${VAR}"` not `${VAR}`
   - Always test syntax: `bash -n script.sh`
   - Use proper trap: `trap 'rm -rf "${DIR}"' EXIT`
   - Validate with shellcheck: `shellcheck -x script.sh`

2. **YAML Files (.yml, .yaml)**
   - Start with: `---`
   - Comment spacing: 2 spaces before `#`
   - Line length: max 80 chars
   - Validate: `yamllint -d .trunk/configs/.yamllint.yaml file.yml`

3. **JSON Files (.json)**
   - Use jq to validate: `jq empty file.json`
   - Plugin manifests must have required fields

### Phase 3: Testing

**MANDATORY TEST EXECUTION:**

```bash
# 1. Run full integration test suite
./integration_tests/run.sh --verbose

# Expected output:
# === Test Summary ===
# Passed: 4
# All tests passed!
```

**Test Success Criteria:**
- ✅ Manifest validation MUST pass
- ✅ Plugin installation MUST pass
- ✅ Plugin loading MUST pass
- ✅ Component discovery MUST pass

**If ANY test fails:**
- Stop immediately
- Print detailed error output
- Investigate root cause
- Fix the issue
- Re-run tests
- Repeat until all tests pass
- Do NOT commit broken code

### Phase 4: Linting

**MANDATORY LINTING:**

```bash
# Run comprehensive linting
bash .claude/skills/lint-fix/lint-fix.sh

# Or individual linters:
shellcheck -x integration_tests/*.sh .claude/skills/lint-fix/*.sh
yamllint -d .trunk/configs/.yamllint.yaml .github/workflows/*.yml .trunk/trunk.yaml
```

**Fix ALL errors (warnings are acceptable if documented)**

### Phase 5: Commit and Push

```bash
# 1. Check what changed
git status

# 2. Stage changes
git add <files>

# 3. Create clear commit message
git commit -m "$(cat <<'EOF'
Description of what was fixed

- Bullet point of changes
- Another change if applicable
- Technical details if needed

https://claude.ai/code/session_<SESSION_ID>
EOF
)"

# 4. Verify commit
git log -1

# 5. Push to feature branch
git push -u origin claude/test-docker-plugin-install-26yZx
```

**Commit Message Requirements:**
- Clear description of what was changed
- Bullet points explaining the changes
- Include session URL for traceability
- Explain WHY the change was necessary

### Phase 6: Verification

After commit:

```bash
# 1. Verify push succeeded
git status  # Should say "Your branch is up to date"

# 2. Run tests one more time
./integration_tests/run.sh

# 3. Verify linting still passes
bash .claude/skills/lint-fix/lint-fix.sh
```

## Decision Trees

### When a Test Fails

```
Test fails
  ↓
Print full error output
  ↓
Identify the failing component:
  - Manifest validation? → Check .claude-plugin/plugin.json
  - Plugin install? → Check build-plugin.sh and test-plugin-install.sh
  - Plugin loading? → Check Claude CLI integration
  - Component discovery? → Check file structure
  ↓
Fix the issue
  ↓
Run tests again
  ↓
All pass? → Continue
  ↓
Still failing? → Investigate deeper, ask for help
```

### When Linting Fails

```
Linting fails
  ↓
Identify linter type:
  - shellcheck? → Fix shell script issues
  - yamllint? → Fix YAML formatting
  - actionlint? → Fix GitHub Actions syntax
  ↓
Fix ALL errors
  ↓
Re-run linting
  ↓
All pass? → Proceed to commit
  ↓
Still failing? → Investigate specific rule
```

### When You're Unsure

```
Unsure about approach
  ↓
Check recent commits:
  git log --oneline -5
  ↓
Review similar changes in git history
  ↓
Check claude.md for patterns
  ↓
Check agents.md for guidelines
  ↓
Still unsure? → Investigate error carefully, check documentation
```

## Critical Patterns

### Pattern 1: Building Artifacts

```bash
# ✅ CORRECT
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "${BUILD_DIR}"' EXIT  # Proper quoting

cd "${BUILD_DIR}" || exit 1
tar -czf "${ARTIFACT_PATH}" "${PLUGIN_NAME}/"
cd - || exit 1

# Output the path
echo "${ARTIFACT_PATH}"
```

### Pattern 2: Testing Extraction

```bash
# ✅ CORRECT
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_DIR}"' EXIT

ARTIFACT_PATH=$(build_script 2>&1 | tail -1)
if [[ -z "${ARTIFACT_PATH}" ]]; then
    echo "ERROR: Build failed"
    exit 1
fi

if ! tar -xzf "${ARTIFACT_PATH}" -C "${TEMP_DIR}"; then
    echo "ERROR: Extraction failed"
    exit 1
fi

PLUGIN_NAME="${plugin##*/}"  # Extract just plugin name
if [[ ! -f "${TEMP_DIR}/${PLUGIN_NAME}/.claude-plugin/plugin.json" ]]; then
    echo "ERROR: Manifest not found"
    exit 1
fi
```

### Pattern 3: YAML Workflow

```yaml
---  # ALWAYS start with document marker
name: My Workflow

on:
  push:
    branches:
      - "**"
  pull_request: {}  # Two spaces before comment
  workflow_dispatch: {}  # Two spaces before comment

permissions:
  contents: read  # Job-level overrides this

jobs:
  my-job:
    runs-on: ubuntu-latest
    permissions:
      checks: write  # Can override workflow-level
      contents: read

    steps:
      - uses: actions/checkout@v6
      - run: ./integration_tests/run.sh --verbose
```

## Metrics and Success

### Code Quality Metrics

Track these for the project:
- ✅ Test pass rate: 100% (all 4 tests)
- ✅ Linting error rate: 0% (no errors)
- ✅ Script syntax valid: 100%
- ✅ YAML valid: 100%
- ✅ Commit completion rate: 100%

### Agent Performance

An agent task is successful when:
- ✅ Tests run and pass
- ✅ Linting runs and passes
- ✅ Code is committed with clear message
- ✅ Code is pushed to feature branch
- ✅ No regressions introduced
- ✅ No manual fixes needed

### Learning From Mistakes

Common mistakes agents have made (NEVER repeat):
1. ❌ Using unquoted variables in trap commands
2. ❌ Not checking error codes from pipelines
3. ❌ Forgetting to quote shell variables
4. ❌ Not validating YAML syntax
5. ❌ Running only some tests, not all
6. ❌ Committing without running tests
7. ❌ Assuming artifact paths without verification
8. ❌ Using wrong permissions in workflows

## Autonomous Agent Checklist

Before marking a task complete:

- [ ] All integration tests pass (./integration_tests/run.sh)
- [ ] All shell scripts pass syntax check (bash -n)
- [ ] All YAML files pass linting (yamllint)
- [ ] No linting errors exist (warnings acceptable)
- [ ] Code is committed with clear message
- [ ] Commit includes session URL
- [ ] Code is pushed to feature branch
- [ ] git status shows clean working tree
- [ ] No regressions from previous work
- [ ] All tests still pass after commit

## Environment Variables

When working in Claude Code cloud:

```bash
# These may be set automatically:
CI=true                    # Running in CI environment
GITHUB_ACTIONS=true        # GitHub Actions environment
GIT_AUTHOR_NAME="..."      # Git configuration
GIT_AUTHOR_EMAIL="..."     # Git configuration

# Feature branch:
FEATURE_BRANCH="claude/test-docker-plugin-install-26yZx"
SESSION_ID="<from URL>"
```

## Resources

- Claude Code Documentation: https://docs.anthropic.com/claude-code
- Trunk Documentation: https://docs.trunk.io
- GitHub Actions: https://docs.github.com/en/actions
- Shell Script Best Practices: https://www.shellcheck.net
- YAML Specification: https://yaml.org

## Support

If an agent encounters an issue:

1. **Check claude.md** for project-specific guidelines
2. **Check agents.md** (this file) for agent guidelines
3. **Review recent commits** for working patterns
4. **Check error messages carefully** - they usually indicate the fix
5. **Run tests with --verbose** for detailed output
6. **Never proceed with broken code** - always fix issues

Remember: **Don't repeat the same mistake!** Learn from previous sessions and apply those lessons to new work.
