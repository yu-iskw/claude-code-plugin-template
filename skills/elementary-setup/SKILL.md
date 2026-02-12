---
name: elementary-setup
description: Set up Elementary data observability for dbt project. Use when initializing Elementary monitoring or configuring alerts.
---

# Elementary Setup Skill

## Purpose

Install and configure Elementary data observability package for dbt projects, including anomaly detection tests, schema monitoring, and alerting integrations.

## Inputs

- **Installation type**: New setup or update existing
- **Alert channels**: Slack, email, webhook, or none
- **Monitoring scope**: All models or specific selection
- **Test coverage level**: Basic, standard, or comprehensive

## Steps

1. **Install Elementary Package**
   - Add Elementary to packages.yml
   - Run `dbt deps` to install
   - Verify package installation

2. **Configure dbt Project**
   - Add Elementary vars to dbt_project.yml
   - Configure alert channels (Slack, email)
   - Set Elementary schema
   - Configure timezone and other settings

3. **Set Up Elementary Models**
   - Run `dbt run --select elementary`
   - Create Elementary schema and tables
   - Verify model execution

4. **Add Elementary Tests**
   - Add volume anomaly tests to key models
   - Set up freshness monitoring
   - Enable schema change detection
   - Configure test sensitivity

5. **Configure Alerts**
   - Set up Slack webhook (if using)
   - Configure email settings (if using)
   - Test alert delivery
   - Set alert routing rules

6. **Install Elementary CLI**
   - Install Elementary CLI tool
   - Configure CLI connection
   - Generate initial report
   - Set up monitoring schedule

7. **Verify Setup**
   - Run Elementary tests
   - Generate Elementary report
   - Check UI access (if using Elementary Cloud)
   - Verify alerts are working

## Output

- Installed and configured Elementary package
- Elementary tests added to models
- Configured alert channels
- Elementary CLI installed and configured
- Initial observability report
- Setup documentation

## Installation Steps

### 1. Add Package
```yaml
# packages.yml
packages:
  - package: elementary-data/elementary
    version: 0.15.0  # Use latest version
```

```bash
dbt deps
```

### 2. Configure Project
```yaml
# dbt_project.yml
vars:
  # Elementary configuration
  elementary:
    # Slack alerts (optional)
    slack_token: "{{ env_var('ELEMENTARY_SLACK_TOKEN', '') }}"
    slack_channel_name: "data-alerts"

    # Alert grouping
    slack_workflows: true

    # Timezone
    timezone: "America/New_York"

    # Elementary schema
    elementary_schema: "elementary"

    # Days back for anomaly detection training
    days_back: 14

models:
  elementary:
    +schema: elementary
```

### 3. Run Elementary Models
```bash
# Create Elementary tables
dbt run --select elementary

# Run incrementally going forward
dbt run
```

### 4. Add Elementary Tests

#### Basic Setup (Volume & Freshness)
```yaml
# models/marts/schema.yml
version: 2

models:
  - name: fct_orders
    tests:
      # Volume anomaly detection
      - elementary.volume_anomalies:
          timestamp_column: created_at
          sensitivity: 3

      # Freshness monitoring
      - elementary.freshness_anomalies:
          timestamp_column: created_at
          sensitivity: 3

      # Schema change monitoring
      - elementary.schema_changes:
          severity: warn
```

#### Comprehensive Setup
```yaml
models:
  - name: fct_orders
    tests:
      # Table-level tests
      - elementary.volume_anomalies:
          timestamp_column: created_at
          where_expression: "status != 'test'"
          sensitivity: 3

      - elementary.freshness_anomalies:
          timestamp_column: created_at
          sensitivity: 3

      - elementary.all_columns_anomalies:
          timestamp_column: created_at
          sensitivity: 3

      - elementary.schema_changes:
          severity: warn

    columns:
      - name: order_total
        tests:
          # Column-level anomaly detection
          - elementary.column_anomalies:
              timestamp_column: created_at
              sensitivity: 3
```

## Alert Configuration

### Slack Setup

1. Create Slack app and get bot token
2. Add token to environment:
```bash
export ELEMENTARY_SLACK_TOKEN="xoxb-your-token"
```

3. Configure in dbt_project.yml (see above)

4. Test alert:
```bash
dbt test --select elementary
```

### Email Setup
```yaml
vars:
  elementary:
    email_from: "alerts@company.com"
    email_to: "data-team@company.com"
    smtp_host: "smtp.gmail.com"
    smtp_port: 587
    smtp_user: "{{ env_var('SMTP_USER') }}"
    smtp_password: "{{ env_var('SMTP_PASSWORD') }}"
```

## Elementary CLI

### Installation
```bash
pip install elementary-data
```

### Configuration
```bash
# Initialize config
edr init

# Or set connection manually
export DBT_PROFILES_DIR=/path/to/profiles
export DBT_PROJECT_DIR=/path/to/project
```

### Generate Report
```bash
# Generate HTML report
edr report

# Open in browser
edr report --open

# Send to Slack
edr monitor --slack-webhook $SLACK_WEBHOOK

# Continuous monitoring
edr monitor --days-back 7
```

## Monitoring Schedule

### Local/Manual
```bash
# Run daily
dbt test
edr report --open
```

### CI/CD
```yaml
# .github/workflows/elementary-monitor.yml
name: Elementary Monitoring

on:
  schedule:
    - cron: '0 8 * * *'  # Daily at 8am

jobs:
  monitor:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Run dbt tests
        run: |
          dbt deps
          dbt test

      - name: Generate Elementary report
        run: |
          pip install elementary-data
          edr monitor --slack-webhook ${{ secrets.SLACK_WEBHOOK }}
```

### Elementary Cloud
- Sign up at elementary-data.com
- Connect dbt project
- Automated monitoring and alerting
- Web UI for reports and alerts

## Test Coverage Strategy

### Tier 1: Critical Models (Comprehensive)
- All anomaly tests
- Schema change monitoring
- Slack alerts on failures

### Tier 2: Important Models (Standard)
- Volume and freshness anomalies
- Schema change monitoring
- Email alerts

### Tier 3: Other Models (Basic)
- Volume anomalies only
- Warning severity

## Progressive Disclosure

- `references/elementary-tests.md` - Complete test catalog
- `references/alert-channels.md` - Alert configuration options
- `references/cli-commands.md` - Elementary CLI reference
- `scripts/setup-elementary.sh` - Automated setup script
- `assets/test-templates/` - Elementary test templates

## Example Usage

- `/elementary-setup install and configure Elementary`
- `/elementary-setup add Slack alerts`
- `/elementary-setup add monitoring to all mart models`
- `/elementary-setup generate initial report`
