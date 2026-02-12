---
name: dbt-test
description: Add dbt tests to models for data quality validation. Use when implementing test coverage or investigating test failures.
---

# dbt Test Skill

## Purpose

Add comprehensive dbt tests to models for data quality validation, including generic tests, singular tests, and package-provided tests.

## Inputs

- **Models to test**: Specific models or all models in a layer
- **Test types**: Generic tests, singular tests, or both
- **Coverage level**: Basic, standard, or comprehensive
- **Test packages**: dbt-utils, dbt-expectations, Elementary

## Steps

1. **Analyze Model Requirements**
   - Review model schema and business logic
   - Identify columns requiring validation
   - Determine relationship dependencies
   - Consider data quality risks

2. **Add Generic Tests**
   - Add unique tests for primary keys
   - Add not_null tests for required columns
   - Add relationships tests for foreign keys
   - Add accepted_values tests for enums

3. **Add Package Tests**
   - Use dbt-utils tests for advanced validation
   - Add dbt-expectations for statistical tests
   - Include Elementary anomaly detection tests

4. **Create Singular Tests**
   - Write SQL-based custom tests for complex logic
   - Add business rule validation queries
   - Create cross-table consistency checks

5. **Run and Validate Tests**
   - Run `dbt test --select <model_name>`
   - Review test results and failures
   - Adjust test configurations as needed

## Output

- Updated schema.yml with generic tests
- Singular test SQL files in tests/ directory
- Test execution results
- Documentation of test coverage
- Recommended additional tests

## Test Templates

### Generic Tests in schema.yml
```yaml
version: 2

models:
  - name: fct_orders
    description: "Order transactions fact table"
    tests:
      # Table-level tests
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - order_id
            - line_item_id
    columns:
      - name: order_id
        description: "Unique order identifier"
        tests:
          - not_null
          - unique

      - name: customer_id
        description: "Foreign key to customers"
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id

      - name: order_status
        description: "Current order status"
        tests:
          - not_null
          - accepted_values:
              values: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled']

      - name: order_total
        description: "Total order amount"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"

      - name: created_at
        description: "Order creation timestamp"
        tests:
          - not_null
          - dbt_utils.recency:
              datepart: day
              interval: 1
```

### dbt-expectations Tests
```yaml
models:
  - name: fct_orders
    tests:
      # Row count validation
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1000
          max_value: 1000000

    columns:
      - name: order_total
        tests:
          # Statistical tests
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100000
          - dbt_expectations.expect_column_mean_to_be_between:
              min_value: 10
              max_value: 500

      - name: email
        tests:
          # Format validation
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
```

### Elementary Tests
```yaml
models:
  - name: fct_orders
    tests:
      # Anomaly detection
      - elementary.volume_anomalies:
          timestamp_column: created_at
          sensitivity: 3

      - elementary.freshness_anomalies:
          timestamp_column: created_at
          sensitivity: 3

      - elementary.schema_changes:
          severity: warn

    columns:
      - name: order_total
        tests:
          - elementary.column_anomalies:
              sensitivity: 3
```

### Singular Test Example
```sql
-- tests/assert_order_totals_match_line_items.sql

-- Test that order totals equal sum of line item amounts

with order_totals as (
    select
        order_id,
        order_total
    from {{ ref('fct_orders') }}
),

line_item_totals as (
    select
        order_id,
        sum(line_total) as calculated_total
    from {{ ref('fct_order_line_items') }}
    group by 1
),

validation as (
    select
        o.order_id,
        o.order_total,
        l.calculated_total,
        abs(o.order_total - l.calculated_total) as difference
    from order_totals o
    join line_item_totals l
        on o.order_id = l.order_id
    where abs(o.order_total - l.calculated_total) > 0.01
)

select * from validation
```

## Test Coverage Strategy

### Basic Coverage (Minimum)
- Unique tests on primary keys
- Not null tests on required columns
- Relationships tests for foreign keys

### Standard Coverage (Recommended)
- Basic coverage +
- Accepted values for categorical columns
- Expression tests for numeric ranges
- Recency tests for timestamp columns

### Comprehensive Coverage
- Standard coverage +
- Elementary anomaly detection
- dbt-expectations statistical tests
- Singular tests for business logic
- Schema change monitoring

## Test Configuration

### Store Failures
```yaml
tests:
  - unique:
      config:
        store_failures: true
        severity: error
```

### Test Severity
```yaml
tests:
  - not_null:
      config:
        severity: warn  # or 'error'
```

### Conditional Tests
```yaml
tests:
  - unique:
      config:
        where: "is_deleted = false"
```

## Progressive Disclosure

- `references/test-catalog.md` - Complete test type reference
- `references/package-tests.md` - dbt-utils and expectations tests
- `scripts/generate-test-coverage.sh` - Coverage analysis script
- `assets/test-templates/` - Test template library

## Example Usage

- `/dbt-test add basic tests to fct_orders`
- `/dbt-test create comprehensive test coverage for marts`
- `/dbt-test add Elementary anomaly detection to all models`
- `/dbt-test run tests and analyze failures`
