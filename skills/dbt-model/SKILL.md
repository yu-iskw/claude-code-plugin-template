---
name: dbt-model
description: Create or modify dbt models with proper SQL, configuration, and documentation. Use when building new models or refactoring existing transformations.
---

# dbt Model Skill

## Purpose

Create new dbt models or modify existing ones following dbt best practices for SQL development, configuration, and documentation.

## Inputs

- **Model type**: staging, intermediate, or mart
- **Model name**: Name following dbt conventions
- **Source data**: Source tables or upstream models
- **Business logic**: Transformation requirements
- **Materialization**: (optional) view, table, incremental, ephemeral

## Steps

1. **Understand Requirements**
   - Identify source data and dependencies
   - Clarify business logic and transformations
   - Determine appropriate model layer (staging/intermediate/mart)

2. **Create Model File**
   - Place in correct directory based on layer
   - Follow naming conventions (stg_, int_, fct_, dim_)
   - Write SQL using dbt features (ref, source, macros)

3. **Configure Model**
   - Add model config block for materialization
   - Set appropriate tags
   - Configure incremental strategy if applicable
   - Add pre/post-hooks if needed

4. **Document Model**
   - Create or update schema.yml
   - Add model description
   - Document all columns
   - Add appropriate tests

5. **Test Model**
   - Run `dbt compile` to check for errors
   - Run `dbt run --select <model_name>` to build
   - Verify output with sample queries

## Output

- SQL model file in appropriate directory
- schema.yml entry with documentation
- Configured materialization and settings
- Basic data quality tests
- Compiled and tested model

## Model Templates

### Staging Model Template
```sql
{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

with source as (
    select * from {{ source('source_name', 'table_name') }}
),

renamed as (
    select
        id,
        created_at,
        updated_at,
        -- Add meaningful column names
        raw_column_1 as column_1,
        raw_column_2 as column_2
    from source
)

select * from renamed
```

### Intermediate Model Template
```sql
{{
    config(
        materialized='ephemeral',
        tags=['intermediate']
    )
}}

with base_table as (
    select * from {{ ref('stg_base_table') }}
),

transformed as (
    select
        id,
        -- Business logic transformations
        case
            when condition then 'value'
            else 'other'
        end as category
    from base_table
)

select * from transformed
```

### Mart Model Template (Fact Table)
```sql
{{
    config(
        materialized='table',
        tags=['mart', 'finance']
    )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

final as (
    select
        orders.order_id,
        orders.order_date,
        customers.customer_name,
        orders.order_total
    from orders
    left join customers
        on orders.customer_id = customers.customer_id
)

select * from final
```

### Incremental Model Template
```sql
{{
    config(
        materialized='incremental',
        unique_key='id',
        on_schema_change='fail'
    )
}}

select
    id,
    created_at,
    updated_at,
    status
from {{ source('app', 'events') }}

{% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
```

## Schema YAML Template
```yaml
version: 2

models:
  - name: fct_orders
    description: "Fact table containing all order transactions"
    columns:
      - name: order_id
        description: "Unique identifier for each order"
        tests:
          - unique
          - not_null
      - name: customer_id
        description: "Foreign key to customers dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id
      - name: order_date
        description: "Date when the order was placed"
        tests:
          - not_null
      - name: order_total
        description: "Total order amount in USD"
        tests:
          - not_null
```

## Best Practices

- Use CTEs (with statements) for readability
- Follow the import → logical → final CTE pattern
- Add meaningful column aliases in staging models
- Keep intermediate models ephemeral when possible
- Use incremental materialization for large, append-only tables
- Always add descriptions and tests
- Use dbt macros for repeated logic

## Progressive Disclosure

- `references/naming-conventions.md` - Model and column naming standards
- `references/sql-style-guide.md` - SQL formatting best practices
- `references/incremental-strategies.md` - Incremental model patterns
- `assets/templates/` - Additional model templates

## Example Usage

- `/dbt-model create staging model for users table`
- `/dbt-model refactor this model to use incremental materialization`
- `/dbt-model create mart for customer lifetime value`
