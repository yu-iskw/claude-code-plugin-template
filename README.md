# dbt + Lightdash + Elementary Plugin for Claude Code

Comprehensive Claude Code plugin for professional dbt development with integrated Lightdash BI and Elementary data observability.

## Overview

This plugin provides a complete toolkit for modern analytics engineering:

- **dbt Development**: Expert agents for building, testing, and documenting dbt models
- **Lightdash Integration**: Metric definition and dashboard creation for BI
- **Elementary Observability**: Automated data quality monitoring and anomaly detection
- **Coordinated Teams**: Multi-agent workflows for complex analytics projects
- **Automation Hooks**: Smart suggestions and validation during development
- **Best Practices**: Built-in rules and guidelines for dbt, Lightdash, and Elementary

## Components

### Sub-Agents (7)

Specialized autonomous agents for different aspects of analytics engineering:

**dbt Core Agents**
- `dbt-developer`: Build and refactor dbt models following best practices
- `dbt-debugger`: Troubleshoot errors, performance issues, and test failures
- `dbt-tester`: Add comprehensive data quality tests

**Lightdash Agents**
- `lightdash-metrics`: Define metrics, dimensions, and measures in YAML
- `lightdash-dashboard`: Design and build BI dashboards

**Elementary Agents**
- `elementary-monitor`: Configure data quality monitoring and anomaly detection
- `elementary-tester`: Analyze data quality reports and investigate issues

### Skills (7)

User-invocable capabilities for common operations:

- `/dbt-init`: Initialize or configure dbt project
- `/dbt-model`: Create or modify dbt models
- `/dbt-test`: Add comprehensive test coverage
- `/dbt-docs`: Generate and serve dbt documentation
- `/lightdash-deploy`: Deploy Lightdash metrics and configurations
- `/elementary-setup`: Set up Elementary data observability
- `/elementary-report`: Generate and analyze data quality reports

### Agent Teams (3)

Coordinated multi-agent workflows:

- `data-quality-team`: Build models with comprehensive testing (dbt-developer + dbt-tester + elementary-monitor)
- `analytics-team`: Develop metric-driven analytics (dbt-developer + lightdash-metrics + lightdash-dashboard)
- `full-stack-team`: End-to-end project management with all agents

### Hooks (8)

Automated assistance and validation:

- `dbt-compile-check`: Auto-compile on model changes
- `suggest-elementary-tests`: Recommend monitoring for new models
- `suggest-dbt-tests`: Remind about test coverage
- `lightdash-validation`: Validate metric definitions
- `dbt-project-structure`: Enforce naming conventions
- `check-dbt-installed`: Verify dbt installation
- `check-elementary-cli`: Verify Elementary CLI
- `pre-commit-validation`: Block commits with compilation errors

### Rules

Best practice guidelines:

- `dbt-best-practices.md`: SQL style, model structure, testing, performance
- `lightdash-conventions.md`: Metric naming, formatting, organization
- `elementary-guidelines.md`: Monitoring coverage, sensitivity tuning, alerting

## Quick Start

### Installation

1. Install the plugin in your Claude Code environment
2. Open a dbt project directory
3. Start using skills and agents

### Basic Workflow

```
# Initialize a new dbt project
/dbt-init

# Create a new model
/dbt-model create staging model for users table

# Add tests and monitoring
/dbt-test add comprehensive coverage to stg_users
/elementary-setup add monitoring to critical models

# Define Lightdash metrics
Use lightdash-metrics agent to add metrics to schema.yml

# Generate documentation
/dbt-docs generate and serve

# Deploy to Lightdash
/lightdash-deploy sync metrics to production
```

### Using Agent Teams

For complex projects, invoke teams for coordinated workflows:

```
Task: Build a new customer analytics mart with BI and monitoring

Use data-quality-team to:
1. Build fct_customer_orders model
2. Add comprehensive dbt tests
3. Configure Elementary anomaly detection

Then use analytics-team to:
1. Define customer metrics (CLV, retention, etc.)
2. Create executive dashboard
```

## Repository Structure

```text
.claude-plugin/
  plugin.json                           # Plugin metadata

agents/                                 # Sub-agents
  dbt-developer.md                      # dbt model development
  dbt-debugger.md                       # Error troubleshooting
  dbt-tester.md                         # Test implementation
  lightdash-metrics.md                  # Metric definitions
  lightdash-dashboard.md                # Dashboard creation
  elementary-monitor.md                 # Observability setup
  elementary-tester.md                  # Quality analysis

skills/                                 # User-invocable skills
  dbt-init/SKILL.md                     # Project initialization
  dbt-model/SKILL.md                    # Model creation
  dbt-test/SKILL.md                     # Test coverage
  dbt-docs/SKILL.md                     # Documentation
  lightdash-deploy/SKILL.md             # Lightdash deployment
  elementary-setup/SKILL.md             # Elementary setup
  elementary-report/SKILL.md            # Quality reporting

teams/                                  # Agent teams
  data-quality-team.json                # Development + testing + monitoring
  analytics-team.json                   # Development + BI
  full-stack-team.json                  # All agents

hooks/
  hooks.json                            # Automation hooks

rules/                                  # Best practices
  dbt-best-practices.md                 # dbt guidelines
  lightdash-conventions.md              # Metric standards
  elementary-guidelines.md              # Monitoring strategy
```

## Features

### Intelligent Automation

- Auto-compile dbt on model changes
- Suggest tests when schema.yml is updated
- Recommend Elementary monitoring for new models
- Validate Lightdash metric syntax
- Enforce dbt naming conventions

### Best Practice Enforcement

- SQL style guidelines
- Model organization (staging/intermediate/marts)
- Test coverage requirements
- Metric naming standards
- Monitoring sensitivity tuning

### Comprehensive Workflows

- Initialize projects with optimal structure
- Build models with proper materialization
- Add multi-layered test coverage
- Define business-friendly metrics
- Create effective dashboards
- Monitor data quality continuously

## Use Cases

### New dbt Project
```
/dbt-init → Set up project structure
/dbt-model → Build initial models
/dbt-test → Add test coverage
/elementary-setup → Configure monitoring
/dbt-docs → Generate documentation
```

### Add BI Layer
```
Use lightdash-metrics agent → Define metrics in YAML
Use lightdash-dashboard agent → Create dashboards
/lightdash-deploy → Deploy to Lightdash
```

### Data Quality Incident
```
/elementary-report → Review quality trends
Use elementary-tester agent → Investigate anomalies
Use dbt-debugger agent → Fix underlying issues
Tune Elementary test sensitivity as needed
```

### Refactoring
```
Use dbt-developer agent → Refactor models
/dbt-test → Update tests
dbt-debugger helps resolve issues
/elementary-report → Verify data quality maintained
```

## Requirements

- **dbt Core**: Version 1.0+
- **dbt Adapter**: For your data warehouse (Snowflake, BigQuery, etc.)
- **Lightdash**: Optional, for BI features
- **Elementary**: Optional, for data observability
- **Git**: For version control
- **Python**: 3.8+ for dbt and Elementary CLI

## Development

### Local Testing

```bash
# Format code
make format

# Run linters
make lint

# Run integration tests
make test-integration-docker
```

### CI/CD

GitHub Actions automatically:
- Validates plugin manifest
- Tests component loading
- Runs linters
- Updates dependencies weekly

## Documentation

- **Plugin Components**: See individual agent and skill files
- **Best Practices**: See `rules/` directory
- **Examples**: Included in skill documentation
- **Integration**: See CLAUDE.md for usage in Claude Code

## Contributing

Contributions welcome! Please:
1. Follow existing patterns for agents/skills/teams
2. Add comprehensive documentation
3. Include examples in skill definitions
4. Update rules as needed
5. Test with integration tests

## License

Apache License 2.0. See `LICENSE`.

## Credits

Built with inspiration from:
- [dbt-labs/dbt-agent-skills](https://github.com/dbt-labs/dbt-agent-skills)
- [Lightdash](https://www.lightdash.com/)
- [Elementary Data](https://www.elementary-data.com/)

## Support

- Issues: GitHub Issues
- Discussions: GitHub Discussions
- Documentation: See `rules/` directory and individual component files
