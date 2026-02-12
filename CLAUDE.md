# dbt + Lightdash + Elementary Plugin

**Professional analytics engineering toolkit for Claude Code**

## What This Plugin Does

This plugin transforms Claude Code into an expert dbt development environment with integrated BI and data observability capabilities.

### Key Capabilities

1. **Build dbt Projects**: Create models, tests, and documentation following best practices
2. **Define Metrics**: Configure Lightdash metrics and dimensions for BI
3. **Monitor Quality**: Set up Elementary data observability and anomaly detection
4. **Automate Workflows**: Get intelligent suggestions and validation during development
5. **Coordinate Teams**: Use multi-agent teams for complex analytics projects

## When to Use This Plugin

### Perfect For

- Analytics engineers building dbt projects
- Data teams using Lightdash for BI
- Teams implementing Elementary for data quality
- Anyone wanting expert guidance on dbt best practices
- Projects requiring coordinated data modeling, testing, and BI

### Use This Plugin When

- Starting a new dbt project
- Building or refactoring dbt models
- Adding test coverage and data quality monitoring
- Defining metrics for dashboards
- Troubleshooting dbt errors or test failures
- Generating dbt documentation
- Deploying Lightdash metrics

## Available Skills

Invoke these with `/skill-name` in Claude Code:

### dbt Core Skills

**`/dbt-init`** - Initialize or configure dbt project
- Set up proper directory structure
- Configure dbt_project.yml
- Install recommended packages
- Create profiles template

**`/dbt-model`** - Create or modify dbt models
- Build staging, intermediate, or mart models
- Configure materializations
- Follow naming conventions
- Add documentation

**`/dbt-test`** - Add comprehensive test coverage
- Generic tests (unique, not_null, relationships)
- Package tests (dbt-utils, dbt-expectations)
- Elementary anomaly detection
- Singular tests for business logic

**`/dbt-docs`** - Generate and serve documentation
- Create schema.yml documentation
- Generate manifest and catalog
- Serve docs locally
- Deploy to hosting platforms

### Lightdash Skills

**`/lightdash-deploy`** - Deploy Lightdash configurations
- Sync dbt models to Lightdash
- Deploy metric definitions
- Preview changes before deployment
- Verify deployment success

### Elementary Skills

**`/elementary-setup`** - Configure Elementary monitoring
- Install Elementary package
- Add anomaly detection tests
- Configure Slack/email alerts
- Set up monitoring coverage

**`/elementary-report`** - Generate data quality reports
- Create HTML reports
- Send Slack summaries
- Analyze anomaly trends
- Investigate test failures

## Available Agents

These agents work autonomously on specific tasks:

### dbt Core Agents

**`dbt-developer`** - Expert dbt model development
- Creates staging, intermediate, and mart models
- Implements SQL transformations
- Configures materializations
- Follows dbt best practices

**`dbt-debugger`** - Troubleshoots dbt issues
- Diagnoses compilation errors
- Fixes test failures
- Optimizes performance
- Resolves dependency issues

**`dbt-tester`** - Implements data quality tests
- Adds generic and singular tests
- Configures test severity
- Uses dbt-utils and dbt-expectations
- Designs test coverage strategy

### Lightdash Agents

**`lightdash-metrics`** - Defines BI metrics
- Creates measures and dimensions
- Configures metric formatting
- Sets up aggregations
- Documents metrics for users

**`lightdash-dashboard`** - Builds dashboards
- Designs dashboard layouts
- Creates visualizations
- Configures filters and interactions
- Organizes content in spaces

### Elementary Agents

**`elementary-monitor`** - Sets up observability
- Configures Elementary tests
- Tunes anomaly detection sensitivity
- Sets up alert channels
- Implements monitoring strategy

**`elementary-tester`** - Analyzes data quality
- Investigates anomaly alerts
- Generates quality reports
- Tunes false positive rates
- Tracks quality trends

## Agent Teams

For complex projects, use coordinated agent teams:

### `data-quality-team`
**Members**: dbt-developer, dbt-tester, elementary-monitor

**Use for**: Building production-ready models with comprehensive testing and monitoring

**Workflow**:
1. dbt-developer creates models
2. dbt-tester adds test coverage
3. elementary-monitor configures observability

### `analytics-team`
**Members**: dbt-developer, lightdash-metrics, lightdash-dashboard

**Use for**: Metric-driven analytics development

**Workflow**:
1. dbt-developer builds data models
2. lightdash-metrics defines metrics
3. lightdash-dashboard creates dashboards

### `full-stack-team`
**Members**: All 7 agents

**Use for**: End-to-end analytics platform development

**Workflow**: Coordinated development, testing, BI, and monitoring

## Automation Hooks

The plugin automatically helps you with:

- **dbt Compilation**: Compiles project when models change
- **Test Suggestions**: Reminds you to add tests to schema.yml
- **Elementary Recommendations**: Suggests monitoring for new models
- **Lightdash Validation**: Validates metric definitions
- **Naming Conventions**: Enforces dbt prefixes (stg_, int_, fct_, dim_)
- **Environment Checks**: Verifies dbt and Elementary CLI are installed

## Example Workflows

### Starting a New dbt Project

```
User: "Initialize a new dbt project for Snowflake"

Claude: Uses /dbt-init skill
- Sets up directory structure
- Configures dbt_project.yml
- Adds recommended packages
- Creates profiles template
```

### Building a Mart Model with Full Coverage

```
User: "Create a customer orders mart model with tests and monitoring"

Claude: Invokes data-quality-team
- dbt-developer: Creates fct_customer_orders.sql
- dbt-tester: Adds tests (unique, not_null, relationships)
- elementary-monitor: Configures volume and freshness anomalies
```

### Creating BI Metrics

```
User: "Define revenue metrics for the orders model"

Claude: Uses lightdash-metrics agent
- Creates total_revenue metric (sum)
- Adds average_order_value (calculated)
- Configures currency formatting
- Sets up time dimensions
```

### Investigating Data Quality Issue

```
User: "Elementary alerted on volume anomaly in fct_orders"

Claude: Uses elementary-tester agent
- Generates Elementary report
- Reviews anomaly details
- Checks historical trends
- Determines if real issue or false positive
- Recommends sensitivity tuning if needed
```

### Deploying to Production

```
User: "Deploy my dbt models and Lightdash metrics to production"

Claude:
1. Compiles dbt project (dbt compile)
2. Runs models (dbt run --select state:modified+)
3. Runs tests (dbt test)
4. Uses /lightdash-deploy to sync metrics
5. Verifies deployment success
```

## Best Practices Built In

The plugin enforces:

### dbt Best Practices
- Model organization (staging/intermediate/marts)
- Naming conventions (stg_, int_, fct_, dim_)
- SQL style (CTEs, explicit columns)
- Materialization strategies
- Test coverage requirements
- Documentation standards

### Lightdash Conventions
- Business-friendly metric names
- Comprehensive metric descriptions
- Appropriate formatting (currency, percentages)
- Dimension configurations
- Metric organization

### Elementary Guidelines
- Tier-based monitoring coverage
- Sensitivity tuning strategies
- Alert channel configuration
- False positive handling
- Report generation schedules

## Configuration

The plugin works best when:

1. **dbt is installed**: `pip install dbt-core dbt-<adapter>`
2. **Elementary package added**: See `/elementary-setup`
3. **Lightdash CLI available**: For `/lightdash-deploy` (optional)
4. **Git repository**: For version control
5. **profiles.yml configured**: For dbt connections

## Tips for Effective Use

### Use Skills for Common Tasks
Quick operations like initializing projects, generating docs, or deploying metrics work best with skills.

### Use Agents for Complex Work
Building models, defining metrics, or setting up monitoring benefit from agent expertise.

### Use Teams for Multi-Step Projects
Coordinated workflows like "build a new mart with BI and monitoring" work best with agent teams.

### Let Hooks Guide You
Pay attention to automatic suggestions for tests, monitoring, and best practices.

### Follow the Rules
Review `rules/` directory for detailed best practice guides.

## Getting Help

### In Claude Code
- Ask: "How do I create an incremental model?"
- Ask: "What Elementary tests should I add?"
- Ask: "Show me best practices for Lightdash metrics"

### Review Documentation
- Agent files: Detailed responsibilities and workflows
- Skill files: Step-by-step procedures
- Rules files: Comprehensive best practices

### Common Questions

**Q: How do I start a new dbt project?**
A: Use `/dbt-init` skill or ask for help initializing the project.

**Q: What's the difference between agents and skills?**
A: Skills are quick user-invocable actions. Agents are autonomous specialists for complex tasks.

**Q: When should I use agent teams?**
A: For multi-faceted projects requiring coordination between development, testing, BI, and monitoring.

**Q: Do I need Lightdash and Elementary?**
A: No, they're optional. Core dbt functionality works standalone.

**Q: How do I customize the hooks?**
A: Edit `hooks/hooks.json` to modify automation behavior.

## What Makes This Plugin Special

1. **Comprehensive**: Covers entire analytics engineering stack (dbt + BI + observability)
2. **Expert Guidance**: Built-in best practices from the dbt community
3. **Coordinated Workflows**: Agent teams work together seamlessly
4. **Intelligent Automation**: Hooks provide contextual suggestions
5. **Battle-Tested Patterns**: Follows established dbt conventions

## Version

Current version: 1.0.0

Compatible with:
- dbt Core 1.0+
- Lightdash (all versions)
- Elementary 0.15.0+

## License

Apache License 2.0
