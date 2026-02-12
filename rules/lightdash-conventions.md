# Lightdash Conventions

Guidelines for defining metrics and dimensions in Lightdash.

## Metric Naming

### Naming Standards
- Use clear, business-friendly names (not technical jargon)
- Use snake_case for metric IDs
- Use Title Case for display names
- Be specific and descriptive

### Examples
```yaml
# Good
total_revenue:
  type: sum
  description: "Total revenue across all transactions"

# Bad
rev:
  type: sum
  description: "Revenue"
```

## Metric Types

### Simple Aggregations
Use for direct column aggregations:
```yaml
columns:
  - name: order_total
    meta:
      metrics:
        total_revenue:
          type: sum
          format: usd
          round: 2

        average_order_value:
          type: average
          format: usd
          round: 2
```

### Calculated Metrics
Use for metric combinations:
```yaml
meta:
  metrics:
    conversion_rate:
      type: number
      sql: "${completed_orders} / NULLIF(${total_orders}, 0)"
      format: percent
      round: 2
      description: "Percentage of orders that completed"
```

### Count Distinct
For unique value counts:
```yaml
columns:
  - name: customer_id
    meta:
      metrics:
        unique_customers:
          type: count_distinct
          description: "Number of unique customers"
```

## Dimensions

### Time Dimensions
Always configure time intervals:
```yaml
columns:
  - name: created_at
    meta:
      dimension:
        type: timestamp
        time_intervals: [day, week, month, quarter, year]
        description: "Order creation timestamp"
```

### Categorical Dimensions
```yaml
columns:
  - name: order_status
    meta:
      dimension:
        type: string
        description: "Current order status"
```

### Numerical Dimensions
For filtering/grouping on numbers:
```yaml
columns:
  - name: customer_age
    meta:
      dimension:
        type: number
        description: "Customer age in years"
```

## Formatting

### Currency
```yaml
metrics:
  total_revenue:
    type: sum
    format: usd  # or 'eur', 'gbp'
    round: 2
```

### Percentages
```yaml
metrics:
  conversion_rate:
    type: average
    format: percent
    round: 1
```

### Numbers
```yaml
metrics:
  total_orders:
    type: count
    format: km  # Thousands/millions (1.2K, 1.5M)
    # or 'id' for raw numbers
```

## Organization

### Group Related Metrics
```yaml
models:
  - name: fct_orders
    meta:
      metrics:
        # Revenue Metrics
        total_revenue:
          type: sum

        # Volume Metrics
        total_orders:
          type: count

        # Average Metrics
        average_order_value:
          type: average
```

### Use Meaningful Groups
- Revenue metrics together
- Count/volume metrics together
- Rate/percentage metrics together
- Efficiency metrics together

## Documentation

### Metric Descriptions
Every metric must explain:
- What it measures
- How it's calculated (if complex)
- When to use it
- Any caveats or limitations

### Good Examples
```yaml
metrics:
  monthly_recurring_revenue:
    type: sum
    description: "Sum of all active subscription values, normalized to monthly. Annual subscriptions are divided by 12. Excludes one-time charges."

  customer_lifetime_value:
    type: average
    description: "Average total revenue per customer from first to last transaction. Calculated as total_revenue / unique_customers. Use for cohort analysis."
```

### Bad Examples
```yaml
metrics:
  mrr:
    type: sum
    description: "MRR"  # Too vague, uses acronym

  value:
    type: average
    description: "Customer value"  # Unclear calculation
```

## Filters and Defaults

### Default Filters
```yaml
metrics:
  active_customer_revenue:
    type: sum
    filters:
      - customer_status: 'active'
    description: "Revenue from active customers only"
```

### Default Time Dimensions
```yaml
columns:
  - name: revenue
    meta:
      metrics:
        total_revenue:
          type: sum
          timestamp_column: order_date  # Default time dimension
```

## Hidden Metrics

Hide intermediate metrics from users:
```yaml
metrics:
  _total_clicks:  # Underscore prefix = hidden
    type: sum
    hidden: true

  click_through_rate:
    type: number
    sql: "${_total_clicks} / NULLIF(${impressions}, 0)"
```

## Metric Relationships

### Building Block Pattern
```yaml
# Base metrics
metrics:
  total_revenue:
    type: sum

  total_orders:
    type: count_distinct

  # Calculated from base metrics
  average_order_value:
    type: number
    sql: "${total_revenue} / NULLIF(${total_orders}, 0)"
    format: usd
    round: 2
```

## Deployment

### Pre-Deployment Checklist
Before deploying Lightdash changes:
- [ ] All metrics compile in dbt
- [ ] Metric names are clear and descriptive
- [ ] All metrics have descriptions
- [ ] Formatting is appropriate
- [ ] Time dimensions configured
- [ ] Tested metrics in Lightdash preview
- [ ] Breaking changes communicated to dashboard owners

### Backward Compatibility
When renaming metrics:
```yaml
# Keep old metric as alias
old_metric_name:
  type: sum
  hidden: true  # Hide from new users

new_metric_name:
  type: sum
  description: "Replaces old_metric_name"
```

## Common Patterns

### Cohort Metrics
```yaml
metrics:
  cohort_month:
    type: min
    sql: "DATE_TRUNC('month', ${created_at})"
    description: "Month of first customer transaction"
```

### Running Totals
```yaml
metrics:
  cumulative_revenue:
    type: sum
    sql: "SUM(${revenue}) OVER (ORDER BY ${order_date})"
```

### Period Comparisons
Use Lightdash's built-in comparison features:
- Configure time dimensions properly
- Use dashboard filters for period selection
- Create comparison charts in dashboards

## Anti-Patterns to Avoid

### ❌ Don't
- Don't use technical column names as metric names
- Don't skip metric descriptions
- Don't create metrics without clear business purpose
- Don't hardcode date filters in metrics
- Don't use acronyms without explanation
- Don't create duplicate metrics with different names

### ✅ Do
- Use business-friendly metric names
- Document all metrics comprehensively
- Align metrics with business KPIs
- Use time dimensions for date filtering
- Spell out acronyms or add to description
- Consolidate similar metrics with filters

## Testing Metrics

### Local Testing
1. Run `dbt compile` to check YAML syntax
2. Preview in Lightdash: `lightdash deploy --preview`
3. Test metric calculations in Lightdash UI
4. Verify formatting and display

### Validation Queries
```sql
-- Validate metric calculation
SELECT
    SUM(order_total) as total_revenue,
    COUNT(*) as total_orders,
    SUM(order_total) / COUNT(*) as avg_order_value
FROM {{ ref('fct_orders') }}
WHERE order_date >= '2024-01-01';
```

Compare results with Lightdash dashboard values.

## Example: Complete Metric Definition

```yaml
version: 2

models:
  - name: fct_orders
    description: "Order transactions fact table"

    meta:
      # Table calculations
      metrics:
        average_order_value:
          type: number
          sql: "${total_revenue} / NULLIF(${order_count}, 0)"
          format: usd
          round: 2
          description: "Average revenue per order, calculated as total_revenue / order_count"

    columns:
      # Time dimension
      - name: order_date
        description: "Date when order was placed"
        meta:
          dimension:
            type: timestamp
            time_intervals: [day, week, month, quarter, year]

      # Metrics
      - name: order_total
        description: "Total order amount in USD"
        meta:
          metrics:
            total_revenue:
              type: sum
              format: usd
              round: 2
              description: "Sum of all order totals across time period"

            average_revenue:
              type: average
              format: usd
              round: 2
              description: "Mean order total value"

      - name: order_id
        description: "Unique order identifier"
        meta:
          metrics:
            order_count:
              type: count_distinct
              description: "Total number of unique orders"

      - name: customer_id
        description: "Foreign key to customers"
        meta:
          metrics:
            unique_customers:
              type: count_distinct
              description: "Number of unique customers who placed orders"

      # Categorical dimension
      - name: order_status
        description: "Current order status"
        meta:
          dimension:
            type: string
```
