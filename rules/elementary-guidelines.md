# Elementary Data Observability Guidelines

Best practices for implementing Elementary monitoring in dbt projects.

## Test Coverage Strategy

### Tier-Based Approach

**Tier 1: Critical Models** (Comprehensive monitoring)
- Customer-facing data products
- Financial/regulatory data
- High-impact business metrics
- SLA-bound pipelines

Coverage:
```yaml
tests:
  - elementary.volume_anomalies
  - elementary.freshness_anomalies
  - elementary.all_columns_anomalies
  - elementary.schema_changes
```

**Tier 2: Important Models** (Standard monitoring)
- Internal analytics
- Operational dashboards
- Regular reports

Coverage:
```yaml
tests:
  - elementary.volume_anomalies
  - elementary.freshness_anomalies
  - elementary.schema_changes
```

**Tier 3: Supporting Models** (Basic monitoring)
- Intermediate transformations
- Low-priority analyses

Coverage:
```yaml
tests:
  - elementary.volume_anomalies
  - elementary.schema_changes:
      severity: warn
```

## Test Configuration

### Volume Anomalies

**Standard Configuration**
```yaml
models:
  - name: fct_orders
    tests:
      - elementary.volume_anomalies:
          timestamp_column: created_at
          sensitivity: 3
          training_period:
            days: 14
```

**With Filters**
```yaml
tests:
  - elementary.volume_anomalies:
      timestamp_column: created_at
      where_expression: "status != 'test' AND is_deleted = false"
      sensitivity: 3
```

**Custom Seasonality**
```yaml
tests:
  - elementary.volume_anomalies:
      timestamp_column: created_at
      seasonality: weekly  # or 'daily', 'monthly'
      sensitivity: 4  # Less sensitive for known patterns
```

### Freshness Anomalies

**Basic Setup**
```yaml
tests:
  - elementary.freshness_anomalies:
      timestamp_column: updated_at
      sensitivity: 3
```

**With Time Bucket**
```yaml
tests:
  - elementary.freshness_anomalies:
      timestamp_column: updated_at
      time_bucket:
        period: hour
        count: 1
      sensitivity: 3
```

### Schema Changes

**Standard Configuration**
```yaml
tests:
  - elementary.schema_changes:
      severity: error  # Fail on schema changes
```

**Warning Only**
```yaml
tests:
  - elementary.schema_changes:
      severity: warn  # Alert but don't fail
```

**With Baseline**
```yaml
tests:
  - elementary.schema_changes_from_baseline:
      fail_on_added: false
      fail_on_removed: true
      fail_on_type_changed: true
```

### Column Anomalies

**Specific Columns**
```yaml
columns:
  - name: revenue
    tests:
      - elementary.column_anomalies:
          timestamp_column: order_date
          sensitivity: 3
          column_anomalies:
            - null_count
            - missing_count
            - zero_count
```

**All Columns**
```yaml
tests:
  - elementary.all_columns_anomalies:
      timestamp_column: created_at
      sensitivity: 3
      exclude_prefix: "_"  # Exclude columns starting with _
```

## Sensitivity Tuning

### Sensitivity Scale (1-4)
- **1**: Very sensitive (many alerts, few missed issues)
- **2**: Moderately sensitive
- **3**: Standard (balanced, recommended default)
- **4**: Less sensitive (fewer alerts, may miss subtle issues)

### When to Adjust

**Increase Sensitivity (use 2 or 1)**
- Critical data with strict SLAs
- New pipelines (while establishing baselines)
- Known data quality issues
- Financial or compliance data

**Decrease Sensitivity (use 4)**
- High variance expected (seasonal, promotional)
- Noisy data sources
- Too many false positives
- Non-critical monitoring

### Tuning Process
1. Start with sensitivity: 3
2. Monitor alerts for 1-2 weeks
3. If too many false positives → increase to 4
4. If missing issues → decrease to 2
5. Document known patterns

## Alert Configuration

### Slack Integration

**Basic Setup**
```yaml
# dbt_project.yml
vars:
  elementary:
    slack_token: "{{ env_var('ELEMENTARY_SLACK_TOKEN') }}"
    slack_channel_name: "data-alerts"
    slack_workflows: true
```

**Channel Routing**
```yaml
# Route different models to different channels
models:
  - name: fct_revenue
    tests:
      - elementary.volume_anomalies:
          config:
            meta:
              slack_channel: "finance-alerts"
```

### Alert Grouping
```yaml
vars:
  elementary:
    slack_workflows: true  # Group related alerts
    alert_suppression_interval: 1  # Hours between repeat alerts
```

### Alert Priorities

**Critical Alerts**
- Send immediately
- Route to on-call channel
- Page if necessary
```yaml
severity: error
```

**Warning Alerts**
- Batch and send hourly/daily
- Route to monitoring channel
```yaml
severity: warn
```

## Training Period

### Standard Training
```yaml
tests:
  - elementary.volume_anomalies:
      training_period:
        days: 14  # Use 2 weeks of history
        count: 14  # Minimum 14 data points
```

### Extended Training
For seasonal patterns:
```yaml
training_period:
  days: 90  # 3 months for quarterly patterns
  count: 60
```

### New Models
For models with limited history:
```yaml
training_period:
  days: 7  # Shorter period
  count: 5  # Fewer required points
```

## Report Generation

### Daily Reports
```bash
# Generate HTML report
edr report --days-back 1 --open

# Send to Slack
edr monitor --slack-webhook $SLACK_WEBHOOK --days-back 1
```

### Weekly Reviews
```bash
# Comprehensive weekly report
edr report --days-back 7 --open

# Focus on failures
edr monitor --slack-webhook $SLACK_WEBHOOK --failures-only
```

### Automated Reporting
```yaml
# GitHub Actions example
- name: Daily Elementary Report
  run: |
    edr monitor \
      --slack-webhook ${{ secrets.SLACK_WEBHOOK }} \
      --days-back 1 \
      --select tag:critical
  schedule:
    - cron: '0 9 * * 1-5'  # Weekdays 9am
```

## Handling False Positives

### Common Causes

**Seasonality**
- Weekend dips
- Holiday patterns
- End-of-month spikes

**Business Events**
- Marketing campaigns
- Sales/promotions
- Product launches

**Technical Events**
- Deployment windows
- Maintenance periods
- Backfills

### Solutions

**1. Adjust Sensitivity**
```yaml
sensitivity: 4  # Less sensitive
```

**2. Add Filters**
```yaml
where_expression: "order_type = 'production'"
```

**3. Extend Training Period**
```yaml
training_period:
  days: 30  # Capture more patterns
```

**4. Document Known Patterns**
Create an issues tracker for recurring false positives:
```markdown
# Known Data Patterns

## Orders Table
- **Weekend dip**: 30-40% lower volume on weekends
- **Black Friday**: 10x spike expected
- **Backfill window**: Every Sunday 2-4am UTC
```

## Schema Change Monitoring

### Critical Tables
Fail on any schema change:
```yaml
tests:
  - elementary.schema_changes:
      severity: error
      fail_on_added: true
      fail_on_removed: true
```

### Evolving Tables
Warn on changes but don't block:
```yaml
tests:
  - elementary.schema_changes:
      severity: warn
```

### Allow Additions
```yaml
tests:
  - elementary.schema_changes:
      fail_on_added: false  # New columns OK
      fail_on_removed: true  # Removed columns fail
```

## Monitoring Best Practices

### ✅ Do
- Start with conservative sensitivity (3)
- Monitor critical models first
- Document known patterns and seasonality
- Review Elementary reports regularly
- Tune based on actual alerts
- Set up appropriate alert channels
- Test alert delivery
- Include timestamp columns in all tests

### ❌ Don't
- Don't add tests without understanding the data
- Don't ignore recurring false positives
- Don't use the same sensitivity for all models
- Don't skip training period configuration
- Don't alert on every issue (use warn when appropriate)
- Don't forget to document alert responses
- Don't deploy without testing locally

## Incident Response

### When Alert Fires

1. **Assess Severity**
   - Critical: Immediate investigation
   - Warning: Add to review queue

2. **Check Elementary UI**
   - View detailed test results
   - Review historical trends
   - Check lineage for upstream issues

3. **Investigate Root Cause**
   - Query affected models
   - Check upstream dependencies
   - Review recent code changes
   - Verify source data

4. **Take Action**
   - Fix data issue if found
   - Tune test if false positive
   - Document pattern if known
   - Update runbooks

5. **Follow Up**
   - Verify fix resolved issue
   - Monitor for recurrence
   - Update test configuration
   - Share learnings with team

## Elementary CLI Commands

### Generate Reports
```bash
# HTML report
edr report --days-back 7

# Open in browser
edr report --open

# Custom output location
edr report --output /path/to/report.html
```

### Monitor
```bash
# Send to Slack
edr monitor --slack-webhook $WEBHOOK

# Filter by tag
edr monitor --select tag:critical

# Failures only
edr monitor --failures-only
```

### Query Results
```sql
-- Recent test results
SELECT * FROM elementary.dbt_tests
WHERE detected_at >= CURRENT_DATE - 7
ORDER BY detected_at DESC;

-- Anomalies
SELECT * FROM elementary.alerts
WHERE alert_type = 'anomaly'
  AND detected_at >= CURRENT_DATE - 7;
```

## Coverage Tracking

### Measure Coverage
```sql
-- Models with Elementary tests
WITH elementary_tested_models AS (
    SELECT DISTINCT model_name
    FROM elementary.dbt_tests
    WHERE test_name LIKE 'elementary%'
)
SELECT
    COUNT(DISTINCT model_name) as total_models,
    COUNT(DISTINCT etm.model_name) as monitored_models,
    ROUND(COUNT(DISTINCT etm.model_name)::FLOAT / COUNT(DISTINCT model_name) * 100, 1) as coverage_pct
FROM dbt_models m
LEFT JOIN elementary_tested_models etm
    ON m.model_name = etm.model_name;
```

### Coverage Goals
- **Critical models**: 100%
- **Important models**: 80%+
- **All models**: 50%+

## Integration with dbt Tests

Elementary complements, not replaces, dbt tests:

**dbt Tests** (Deterministic validation)
- Unique constraints
- Not null checks
- Referential integrity
- Accepted values
- Business rules

**Elementary Tests** (Anomaly detection)
- Volume anomalies
- Freshness monitoring
- Schema changes
- Statistical anomalies

Use both for comprehensive data quality:
```yaml
models:
  - name: fct_orders
    tests:
      # dbt tests
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns: [order_id, line_item_id]

    columns:
      - name: order_id
        tests:
          - not_null
          - unique

      - name: customer_id
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id

      # Elementary tests
      - elementary.volume_anomalies:
          timestamp_column: created_at
          sensitivity: 3

      - elementary.freshness_anomalies:
          timestamp_column: created_at
          sensitivity: 3

      - elementary.schema_changes:
          severity: warn
```
