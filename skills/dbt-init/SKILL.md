---
name: dbt-init
description: Initialize or configure a dbt project with best practices. Use when starting a new dbt project or updating project configuration.
---

# dbt Init Skill

## Purpose

Initialize a new dbt project or update existing project configuration following dbt best practices and modern project structure.

## Inputs

- **Project type**: New project or existing project update
- **Database platform**: Snowflake, BigQuery, Redshift, Postgres, DuckDB, etc.
- **Project name**: (optional for new projects)
- **Configuration options**: (optional) packages, vars, model configs

## Steps

1. **Check Current State**
   - Verify if dbt is installed (`dbt --version`)
   - Check for existing dbt_project.yml
   - Identify database connection type

2. **Initialize or Update Project**
   - For new projects: Run `dbt init <project_name>`
   - For existing: Review and update dbt_project.yml
   - Set up recommended directory structure

3. **Configure Best Practices**
   - Set up model organization (staging, intermediate, mart)
   - Configure materializations by folder
   - Add recommended packages (dbt-utils, Elementary, etc.)
   - Set up profiles.yml template
   - Configure model-level defaults

4. **Add Essential Files**
   - Create .gitignore for dbt artifacts
   - Add packages.yml with recommended packages
   - Set up schema.yml templates
   - Create README.md with project documentation

5. **Install Dependencies**
   - Run `dbt deps` to install packages
   - Verify connection with `dbt debug`

## Output

- Initialized or updated dbt project with:
  - Proper directory structure
  - Configured dbt_project.yml
  - Installed packages
  - Connection profiles template
  - Documentation templates

## Configuration Templates

### Recommended Directory Structure
```
models/
├── staging/          # Raw source transformations
├── intermediate/     # Business logic transformations
├── marts/            # Final business-facing models
│   ├── core/        # Core business entities
│   ├── finance/     # Finance-specific marts
│   └── marketing/   # Marketing-specific marts
tests/                # Singular tests
macros/               # Custom macros
seeds/                # Static reference data
snapshots/            # Snapshot definitions
analyses/             # Ad-hoc queries
```

### dbt_project.yml Template
```yaml
name: 'analytics'
version: '1.0.0'
config-version: 2

profile: 'analytics'

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  analytics:
    staging:
      +materialized: view
    intermediate:
      +materialized: ephemeral
    marts:
      +materialized: table
```

### Recommended packages.yml
```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
  - package: calogica/dbt_expectations
    version: 0.10.1
  - package: elementary-data/elementary
    version: 0.15.0
```

## Progressive Disclosure

Additional configuration details:
- `references/database-configs.md` - Database-specific setup
- `references/package-recommendations.md` - Useful dbt packages
- `scripts/setup-profiles.sh` - Automated profiles.yml generation
- `assets/gitignore-template.txt` - dbt .gitignore template

## Example Usage

- `/dbt-init` - Initialize new dbt project interactively
- `/dbt-init snowflake` - Initialize with Snowflake adapter
- `/dbt-init --update` - Update existing project configuration
