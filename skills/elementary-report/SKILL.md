---
name: elementary-report
description: Generate and analyze Elementary data quality reports. Use when reviewing data quality trends or investigating anomalies.
---

# Elementary Report Skill

## Purpose

Generate comprehensive Elementary data quality reports, analyze trends, investigate anomalies, and share observability insights with stakeholders.

## Inputs

- **Report type**: HTML report, Slack summary, or CLI output
- **Time range**: Days back to include in analysis
- **Scope**: All models or specific selection
- **Output destination**: Local file, Slack, or email

## Steps

1. **Run Elementary Tests**
   - Execute dbt tests to get latest results
   - Run Elementary data collection
   - Verify test execution completed

2. **Generate Report**
   - Run Elementary CLI report command
   - Specify time range and filters
   - Choose output format

3. **Analyze Results**
   - Review test failure summary
   - Identify anomaly patterns
   - Check schema changes
   - Analyze test execution trends

4. **Share Report**
   - Send to Slack channel
   - Email to stakeholders
   - Upload to shared location
   - Open HTML report in browser

5. **Act on Findings**
   - Triage critical issues
   - Create tickets for data issues
   - Tune test sensitivity if needed
   - Document known patterns

## Output

- Elementary data quality report (HTML or Slack)
- Summary of test results and anomalies
- Schema change log
- Recommended actions
- Trend analysis

## Report Generation

### Basic Report Commands

#### Generate HTML Report
```bash
# Default: last 7 days
edr report

# Specify days back
edr report --days-back 30

# Open in browser automatically
edr report --open

# Save to specific location
edr report --output /path/to/report.html

# Select specific models
edr report --select tag:critical
```

#### Send to Slack
```bash
# Send summary to Slack
edr monitor --slack-webhook $SLACK_WEBHOOK

# Include specific days
edr monitor --slack-webhook $SLACK_WEBHOOK --days-back 7

# Filter by tag
edr monitor --slack-webhook $SLACK_WEBHOOK --select tag:critical
```

#### CLI Summary
```bash
# Print summary to console
edr monitor --days-back 7

# Detailed output
edr monitor --days-back 7 --verbose
```

### Advanced Options

```bash
# Generate report from custom profile
edr report --profile-target prod

# Exclude specific tests
edr report --exclude tag:experimental

# Include only failures
edr report --failures-only

# Custom Elementary schema
edr report --elementary-schema custom_elementary
```

## Report Sections

### 1. Executive Summary
- Total tests run
- Pass/fail/warn breakdown
- Critical failures
- Schema changes detected
- Anomalies found

### 2. Test Results
- Test execution status by model
- Failed test details
- Test execution time trends
- Test coverage metrics

### 3. Anomaly Detection
- Volume anomalies by model
- Freshness issues
- Column-level anomalies
- Anomaly severity and impact

### 4. Schema Changes
- New columns added
- Columns removed
- Data type changes
- Table structure modifications

### 5. Model Health
- Model execution status
- Run duration trends
- Row count trends
- Freshness status

### 6. Lineage View
- DAG visualization with test results
- Upstream/downstream impact
- Critical path identification

## Analysis Workflows

### Daily Monitoring Workflow
```bash
# 1. Run dbt tests
dbt test

# 2. Generate report for review
edr report --days-back 1 --open

# 3. Send summary to team
edr monitor --slack-webhook $SLACK_WEBHOOK
```

### Weekly Review Workflow
```bash
# 1. Generate comprehensive report
edr report --days-back 7 --open

# 2. Analyze trends
# Review anomaly patterns
# Check for recurring failures
# Identify schema change impact

# 3. Document findings
# Create tickets for issues
# Tune test sensitivity
# Update monitoring coverage
```

### Incident Investigation
```bash
# 1. Generate detailed report for incident window
edr report --days-back 3 --verbose

# 2. Focus on affected models
edr report --select fct_orders+ --days-back 7

# 3. Review specific test failures
# Check Elementary UI for detailed logs
# Query Elementary tables directly

# 4. Document root cause and resolution
```

## Interpreting Results

### Anomaly Severity

**Critical Anomalies** (Immediate action)
- Large volume drops (>50%)
- Complete freshness failures
- Schema breaking changes

**Warning Anomalies** (Monitor closely)
- Moderate volume changes (20-50%)
- Freshness delays within tolerance
- Non-breaking schema changes

**Info Anomalies** (Review when possible)
- Minor volume variations
- Expected seasonality
- Dimension cardinality changes

### False Positive Handling

Common causes:
- Seasonality (weekends, holidays)
- Known business events (campaigns, sales)
- Deployment windows
- Historical data loads

Solutions:
- Adjust sensitivity parameter
- Add where_expression filters
- Extend training period
- Document expected patterns

## Direct Table Queries

Elementary stores results in tables:

```sql
-- Test results
select * from elementary.dbt_tests
where detected_at >= current_date - 7
order by detected_at desc;

-- Test runs
select * from elementary.dbt_run_results
where created_at >= current_date - 7;

-- Anomalies
select * from elementary.alerts
where detected_at >= current_date - 7
and alert_type = 'anomaly';

-- Schema changes
select * from elementary.schema_changes
where detected_at >= current_date - 30;
```

## Automated Reporting

### Scheduled Reports
```yaml
# .github/workflows/elementary-report.yml
name: Daily Elementary Report

on:
  schedule:
    - cron: '0 9 * * 1-5'  # Weekdays at 9am

jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Generate and send report
        run: |
          pip install elementary-data
          edr monitor \
            --slack-webhook ${{ secrets.SLACK_WEBHOOK }} \
            --days-back 1
```

### Alert on Failures
```yaml
on:
  schedule:
    - cron: '0 * * * *'  # Hourly

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - name: Run tests and alert on failures
        run: |
          dbt test
          if [ $? -ne 0 ]; then
            edr monitor --slack-webhook ${{ secrets.SLACK_WEBHOOK }} --failures-only
          fi
```

## Progressive Disclosure

- `references/report-interpretation.md` - Guide to reading reports
- `references/elementary-tables.md` - Direct database queries
- `references/automation-patterns.md` - Scheduling and CI/CD
- `scripts/generate-report.sh` - Report generation script
- `assets/report-templates/` - Report customization examples

## Example Usage

- `/elementary-report generate report for last 7 days`
- `/elementary-report send daily summary to Slack`
- `/elementary-report investigate anomalies on fct_orders`
- `/elementary-report analyze schema changes this month`
