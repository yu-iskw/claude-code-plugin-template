# dbt Best Practices

These rules should be followed when developing dbt projects with this plugin.

## Project Structure

### Directory Organization
- **staging/**: Raw source transformations only. Prefix models with `stg_`
- **intermediate/**: Business logic transformations. Prefix models with `int_`
- **marts/**: Final business-facing models. Prefix with `fct_` (facts) or `dim_` (dimensions)

### File Naming
- Use snake_case for all file names
- Be descriptive: `fct_customer_orders.sql` not `orders.sql`
- Match file name to model name in SQL

## SQL Style

### CTEs (Common Table Expressions)
```sql
-- Good: Use CTEs for readability
with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

final as (
    select
        orders.order_id,
        customers.customer_name,
        orders.order_total
    from orders
    left join customers on orders.customer_id = customers.customer_id
)

select * from final

-- Bad: Nested subqueries
select
    o.order_id,
    c.customer_name,
    o.order_total
from (select * from {{ ref('stg_orders') }}) o
left join (select * from {{ ref('dim_customers') }}) c
    on o.customer_id = c.customer_id
```

### SELECT Statements
- Always specify columns explicitly (no `select *` in final models)
- Put each column on its own line
- Use trailing commas for easier diffs
- Order columns logically (IDs, attributes, metrics, timestamps)

### Naming
- Use clear, descriptive column names
- Avoid abbreviations unless standard (e.g., `id`, `qty`)
- Use `is_` or `has_` prefix for boolean columns
- Use `_at` suffix for timestamps, `_date` for dates

## Model Configuration

### Materializations
- **staging**: `view` (lightweight, always fresh)
- **intermediate**: `ephemeral` (not materialized, only referenced)
- **marts**: `table` or `incremental` (for large datasets)

### Config Blocks
```sql
-- Always include config at top of model
{{
    config(
        materialized='table',
        tags=['finance', 'daily'],
        schema='marts'
    )
}}
```

### Incremental Models
- Always include `unique_key`
- Set `on_schema_change` strategy
- Use appropriate incremental strategy for your warehouse
- Test thoroughly before deploying

## Documentation

### Model Descriptions
Every model must have:
- Clear one-line summary
- Business purpose explanation
- Grain statement (one row per...)
- Refresh cadence

### Column Descriptions
- Document all columns, especially calculated ones
- Specify units (USD, UTC, etc.)
- Explain business logic for derived columns

### Sources
- Document all sources with descriptions
- Set freshness checks where appropriate
- Include loaded_at timestamp column

## Testing

### Minimum Test Coverage
Every model must have:
- `unique` test on primary key(s)
- `not_null` tests on required columns
- `relationships` tests for foreign keys

### Additional Testing
- `accepted_values` for categorical columns
- Custom singular tests for business logic
- Elementary anomaly detection for critical models

### Test Configuration
```yaml
tests:
  - unique:
      config:
        severity: error  # or 'warn'
        store_failures: true
```

## Performance

### Query Optimization
- Use appropriate materializations
- Leverage incremental models for large tables
- Minimize joins in staging models
- Use CTEs instead of subqueries for readability
- Filter data early in transformations

### Incremental Strategies
- **append**: For immutable event data
- **merge/delete+insert**: For updating records
- **insert_overwrite**: For partition-based updates

## Dependencies

### Ref and Source
- Use `{{ ref('model_name') }}` for dbt models
- Use `{{ source('source_name', 'table_name') }}` for raw tables
- Never hardcode table references

### Model Dependencies
- Keep staging models independent
- Intermediate models depend only on staging
- Marts depend on staging and intermediate
- Avoid circular dependencies

## Packages

### Recommended Packages
```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
  - package: calogica/dbt_expectations
    version: 0.10.1
  - package: elementary-data/elementary
    version: 0.15.0
```

### Macro Usage
- Leverage dbt-utils for common patterns
- Create custom macros for repeated logic
- Document macros with docstrings

## Version Control

### What to Commit
- All model SQL files
- schema.yml files
- dbt_project.yml
- packages.yml
- macros, tests, seeds

### What NOT to Commit
- target/ directory
- dbt_packages/ directory
- logs/ directory
- .user.yml files
- profiles.yml (use profiles_template.yml instead)

## Deployment

### Pre-Deployment Checks
1. Run `dbt compile` to check for errors
2. Run `dbt run --select state:modified+` to test changes
3. Run `dbt test` to verify data quality
4. Review compiled SQL in target/compiled/

### CI/CD
- Run dbt tests on every PR
- Use slim CI with state comparison
- Deploy to production only from main branch
- Run dbt docs generate and publish

## Data Quality

### Elementary Integration
- Add Elementary tests to all mart models
- Configure appropriate sensitivity (3 is standard)
- Set up Slack alerts for anomalies
- Review Elementary reports regularly

### Test Severity
- Use `error` for critical data quality issues
- Use `warn` for monitoring without blocking

## Lightdash Integration

### Metric Definitions
- Define metrics in dbt schema.yml files
- Use clear, business-friendly names
- Add comprehensive descriptions
- Set appropriate formats and rounding

### Metric Best Practices
- Choose correct aggregation type (sum vs average)
- Set default time dimensions
- Use calculated metrics for ratios
- Group related metrics together

## Common Anti-Patterns to Avoid

### ❌ Don't
- Don't use SELECT * in final models
- Don't hardcode database or schema names
- Don't create models without tests
- Don't skip documentation
- Don't commit credentials or secrets
- Don't use UNIONs when a single source is sufficient
- Don't create models without clear business purpose

### ✅ Do
- Use explicit column lists
- Use ref() and source() functions
- Add minimum test coverage to all models
- Document models and columns
- Use environment variables for credentials
- Normalize data when beneficial
- Align models with business needs

## Code Review Checklist

Before submitting dbt changes:
- [ ] All models compile successfully
- [ ] New models follow naming conventions
- [ ] Models are in appropriate layer (staging/intermediate/mart)
- [ ] All models have descriptions
- [ ] All columns are documented
- [ ] Minimum test coverage added
- [ ] Elementary monitoring configured for critical models
- [ ] Materialization is appropriate
- [ ] No hardcoded table references
- [ ] SQL follows style guide
- [ ] Lightdash metrics defined if applicable
