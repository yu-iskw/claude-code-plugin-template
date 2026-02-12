---
name: lightdash-deploy
description: Deploy Lightdash metric and dimension changes. Use when promoting Lightdash configurations or syncing dbt models to Lightdash.
---

# Lightdash Deploy Skill

## Purpose

Deploy Lightdash metric definitions, dimensions, and configuration changes from dbt YAML files to Lightdash, ensuring BI layer stays in sync with data transformations.

## Inputs

- **Deployment scope**: Full sync or specific models
- **Environment**: Development, staging, or production
- **Validation level**: Compile-only or full deployment

## Steps

1. **Pre-Deployment Validation**
   - Verify dbt models compile successfully
   - Check Lightdash YAML syntax
   - Validate metric definitions
   - Review dimension configurations

2. **Compile dbt Project**
   - Run `dbt compile` to ensure no errors
   - Verify all refs and sources resolve
   - Check for schema changes

3. **Preview Changes**
   - Use Lightdash CLI to preview deployment
   - Review metrics being added/modified/removed
   - Check for breaking changes

4. **Deploy to Lightdash**
   - Run Lightdash deploy command
   - Sync dbt models to Lightdash
   - Update metric catalog
   - Refresh Lightdash cache

5. **Verify Deployment**
   - Check Lightdash UI for new metrics
   - Test metrics in explores
   - Verify dashboards still work
   - Review any errors or warnings

## Output

- Deployed metrics and dimensions in Lightdash
- Deployment summary and change log
- Verification test results
- Updated Lightdash project state

## Deployment Commands

### Lightdash CLI

#### Install Lightdash CLI
```bash
npm install -g @lightdash/cli

# Or use npx
npx @lightdash/cli --version
```

#### Login to Lightdash
```bash
lightdash login https://your-org.lightdash.cloud

# Or with API token
lightdash config set-project --api-token $LIGHTDASH_API_TOKEN
```

#### Preview Deployment
```bash
# Preview changes before deploying
lightdash deploy --preview

# Show detailed diff
lightdash deploy --preview --verbose
```

#### Deploy Changes
```bash
# Deploy to default project
lightdash deploy

# Deploy specific models
lightdash deploy --select fct_orders

# Deploy with dbt selector syntax
lightdash deploy --select tag:metrics

# Deploy to specific environment
lightdash deploy --target prod
```

## Pre-Deployment Checklist

### 1. Validate YAML Syntax
- Check for proper indentation
- Verify meta blocks are correctly nested
- Ensure metric types are valid
- Validate dimension configurations

### 2. Test Metrics Locally
- Run dbt compile to catch errors
- Verify SQL in custom metrics
- Check calculated field logic
- Test format strings

### 3. Review Breaking Changes
- Metrics being renamed or removed
- Dimension type changes
- Format or aggregation changes
- Changes affecting existing dashboards

### 4. Check Dependencies
- Ensure upstream models are deployed
- Verify source tables exist
- Check for circular dependencies

## Deployment Strategies

### Development Workflow
```bash
# 1. Make changes to schema.yml
# 2. Test locally
dbt compile --select fct_orders
dbt run --select fct_orders

# 3. Preview Lightdash changes
lightdash deploy --preview --select fct_orders

# 4. Deploy to dev
lightdash deploy --select fct_orders --target dev

# 5. Test in Lightdash UI
# 6. Commit and push to git
```

### Production Deployment
```bash
# 1. Deploy dbt models
dbt run --select state:modified+

# 2. Preview Lightdash deployment
lightdash deploy --preview

# 3. Deploy to production
lightdash deploy --target prod

# 4. Verify in production UI
# 5. Monitor for errors
```

### CI/CD Integration
```yaml
# .github/workflows/lightdash-deploy.yml
name: Deploy Lightdash

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install dbt
        run: pip install dbt-snowflake

      - name: Install Lightdash CLI
        run: npm install -g @lightdash/cli

      - name: Compile dbt
        run: dbt compile

      - name: Preview Lightdash changes
        run: lightdash deploy --preview
        env:
          LIGHTDASH_API_TOKEN: ${{ secrets.LIGHTDASH_API_TOKEN }}

      - name: Deploy to Lightdash
        run: lightdash deploy
        env:
          LIGHTDASH_API_TOKEN: ${{ secrets.LIGHTDASH_API_TOKEN }}
```

## Troubleshooting

### Common Issues

**Deployment fails with "Model not found"**
- Ensure dbt model has been run and exists in warehouse
- Check target environment matches dbt target
- Verify database and schema names

**Metrics not appearing in Lightdash**
- Check YAML syntax and indentation
- Verify meta blocks are under correct keys
- Refresh browser cache
- Check Lightdash project permissions

**Breaking dashboard errors**
- Review changed metric names
- Check for removed dimensions
- Update dashboard configs before deployment
- Use metric aliases for backwards compatibility

## Rollback Procedure

If deployment causes issues:

1. Identify the issue in Lightdash UI
2. Revert YAML changes in dbt
3. Redeploy previous version
4. Test affected dashboards
5. Investigate root cause

## Progressive Disclosure

- `references/lightdash-cli.md` - Complete CLI reference
- `references/metric-types.md` - Metric configuration options
- `references/deployment-strategies.md` - CI/CD patterns
- `scripts/validate-lightdash.sh` - Pre-deployment validation script

## Example Usage

- `/lightdash-deploy preview changes for fct_orders`
- `/lightdash-deploy sync all metrics to production`
- `/lightdash-deploy validate YAML and deploy to dev`
