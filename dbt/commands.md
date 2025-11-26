# dbt Commands Reference Guide

A comprehensive guide to dbt (data build tool) commands organized by use case, environment, and workflow stage.

---

## Table of Contents

1. [Development Environment Commands](#development-environment-commands)
2. [Production Environment Commands](#production-environment-commands)
3. [Testing & Quality Assurance](#testing--quality-assurance)
4. [Documentation Commands](#documentation-commands)
5. [Debugging & Troubleshooting](#debugging--troubleshooting)
6. [Package Management](#package-management)
7. [Project Management](#project-management)
8. [Advanced Selection Syntax](#advanced-selection-syntax)

---

## Development Environment Commands

### Core Build Commands

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt run` | Execute all models in your project | Full refresh of all models | `dbt run` |
| `dbt run --select model_name` | Run a specific model | Testing individual model changes | `dbt run --select customers` |
| `dbt run --select model_name+` | Run a model and all downstream models | Testing impact of changes | `dbt run --select customers+` |
| `dbt run --select +model_name` | Run a model and all upstream models | Ensuring dependencies are built | `dbt run --select +orders` |
| `dbt run --select +model_name+` | Run a model with all dependencies | Complete lineage execution | `dbt run --select +dim_customers+` |
| `dbt run --select path/to/folder/` | Run all models in a folder | Running models by directory | `dbt run --select models/staging/` |
| `dbt run --select tag:daily` | Run models with a specific tag | Tag-based execution | `dbt run --select tag:daily` |
| `dbt run --exclude model_name` | Run all models except specified | Skip problematic models | `dbt run --exclude staging_orders` |
| `dbt run --full-refresh` | Force rebuild incremental models | Reset incremental logic | `dbt run --full-refresh` |

### Incremental Development

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt run --select state:modified` | Run only modified models | Efficient development workflow | `dbt run --select state:modified` |
| `dbt run --select state:modified+` | Run modified models and downstream | Impact analysis after changes | `dbt run --select state:modified+` |
| `dbt run --models @state:modified` | Alternative syntax for modified | Slim CI workflows | `dbt run --models @state:modified` |
| `dbt run --defer --state ./prod-run-artifacts` | Compare against production state | Development without full build | `dbt run --defer --state ./target` |

### Quick Iteration Commands

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt compile` | Generate SQL without executing | Verify SQL compilation | `dbt compile` |
| `dbt compile --select model_name` | Compile specific model | Check individual model SQL | `dbt compile --select customers` |
| `dbt show --select model_name` | Preview model results (5 rows) | Quick data validation | `dbt show --select customers` |
| `dbt show --inline "select * from {{ ref('customers') }}"` | Run ad-hoc SQL query | Quick data exploration | `dbt show --inline "select ..."` |

---

## Production Environment Commands

### Scheduled Production Runs

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt run --target prod` | Run models in production target | Daily production refresh | `dbt run --target prod` |
| `dbt run --target prod --select tag:daily` | Run daily tagged models | Scheduled daily jobs | `dbt run --target prod --select tag:daily` |
| `dbt run --target prod --select tag:hourly` | Run hourly models | Frequent refresh models | `dbt run --target prod --select tag:hourly` |
| `dbt run --target prod --full-refresh --select tag:weekly` | Full refresh weekly models | Weekly full rebuild | `dbt run --target prod --full-refresh --select tag:weekly` |

### Production Build with Tests

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt build --target prod` | Run, test, and snapshot all | Complete production build | `dbt build --target prod` |
| `dbt build --select tag:critical` | Build critical models with tests | High-priority pipeline | `dbt build --select tag:critical` |
| `dbt build --exclude tag:experimental` | Build excluding experimental | Stable production run | `dbt build --exclude tag:experimental` |

### Snapshot Management

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt snapshot` | Create/update all snapshots | Capture SCD Type 2 changes | `dbt snapshot` |
| `dbt snapshot --select snapshot_name` | Run specific snapshot | Target specific SCD tables | `dbt snapshot --select customer_snapshot` |
| `dbt snapshot --target prod` | Run snapshots in production | Production data versioning | `dbt snapshot --target prod` |

### Seed Data Management

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt seed` | Load CSV files into warehouse | Load reference data | `dbt seed` |
| `dbt seed --select seed_name` | Load specific seed file | Update single reference table | `dbt seed --select country_codes` |
| `dbt seed --full-refresh` | Force reload all seeds | Reset seed data | `dbt seed --full-refresh` |
| `dbt seed --target prod` | Load seeds to production | Production seed deployment | `dbt seed --target prod` |

---

## Testing & Quality Assurance

### Test Execution

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt test` | Run all tests in project | Complete quality check | `dbt test` |
| `dbt test --select model_name` | Test specific model | Validate individual model | `dbt test --select customers` |
| `dbt test --select test_type:generic` | Run only generic tests | Schema validation | `dbt test --select test_type:generic` |
| `dbt test --select test_type:singular` | Run only singular tests | Custom business logic tests | `dbt test --select test_type:singular` |
| `dbt test --select tag:critical` | Test critical models only | High-priority validation | `dbt test --select tag:critical` |
| `dbt test --select source:*` | Test all source freshness | Validate source data | `dbt test --select source:*` |
| `dbt test --store-failures` | Save failing rows to warehouse | Debug test failures | `dbt test --store-failures` |

### Source Freshness

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt source freshness` | Check all source freshness | Validate data arrival | `dbt source freshness` |
| `dbt source freshness --select source:source_name` | Check specific source | Target source validation | `dbt source freshness --select source:raw_data` |
| `dbt source freshness --output ./freshness.json` | Output to JSON file | CI/CD integration | `dbt source freshness --output ./freshness.json` |

### Combined Build and Test

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt build` | Run models, tests, snapshots, seeds | Complete workflow execution | `dbt build` |
| `dbt build --select +model_name+` | Build with full lineage testing | End-to-end validation | `dbt build --select +customers+` |
| `dbt build --fail-fast` | Stop on first failure | Quick failure detection | `dbt build --fail-fast` |

---

## Documentation Commands

### Generate Documentation

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt docs generate` | Generate documentation artifacts | Create project docs | `dbt docs generate` |
| `dbt docs generate --target prod` | Generate docs for prod target | Production documentation | `dbt docs generate --target prod` |
| `dbt docs serve` | Launch local documentation site | Browse docs locally | `dbt docs serve` |
| `dbt docs serve --port 8001` | Serve docs on custom port | Avoid port conflicts | `dbt docs serve --port 8001` |

---

## Debugging & Troubleshooting

### Debugging Commands

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt compile --select model_name` | View compiled SQL | Debug SQL logic | `dbt compile --select customers` |
| `dbt run-operation macro_name` | Execute specific macro | Test macro logic | `dbt run-operation grant_select` |
| `dbt run-operation macro_name --args '{key: value}'` | Run macro with arguments | Parameterized macro testing | `dbt run-operation create_schema --args '{schema: analytics}'` |
| `dbt ls` | List all resources | Understand project structure | `dbt ls` |
| `dbt ls --select model_name+` | List model and downstream | Trace dependencies | `dbt ls --select customers+` |
| `dbt ls --resource-type model` | List all models | View all models | `dbt ls --resource-type model` |
| `dbt ls --resource-type test` | List all tests | View all tests | `dbt ls --resource-type test` |
| `dbt ls --output json` | Output as JSON | Programmatic access | `dbt ls --output json` |

### Logging and Verbosity

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt run --debug` | Run with detailed debug logs | Troubleshoot issues | `dbt run --debug` |
| `dbt run --log-level debug` | Set log level explicitly | Control log verbosity | `dbt run --log-level debug` |
| `dbt run --log-format json` | Output logs as JSON | Machine-readable logs | `dbt run --log-format json` |
| `dbt compile --no-version-check` | Skip version check | Avoid version warnings | `dbt compile --no-version-check` |

### Parse and Validate

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt parse` | Parse project files | Validate project structure | `dbt parse` |
| `dbt clean` | Delete target/ and dbt_packages/ | Clean build artifacts | `dbt clean` |
| `dbt debug` | Test database connection | Diagnose connection issues | `dbt debug` |
| `dbt debug --config-dir` | Show configuration location | Find config files | `dbt debug --config-dir` |

---

## Package Management

### Package Commands

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt deps` | Install packages from packages.yml | Setup project dependencies | `dbt deps` |
| `dbt clean` | Remove installed packages | Clean before fresh install | `dbt clean` |
| `dbt deps && dbt run` | Install deps and run | Fresh environment setup | `dbt deps && dbt run` |

---

## Project Management

### Initialization and Setup

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt init project_name` | Create new dbt project | Start new project | `dbt init my_analytics` |
| `dbt init` | Initialize in current directory | Setup existing project | `dbt init` |
| `dbt debug` | Verify connection setup | Initial configuration | `dbt debug` |

### Project Operations

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| `dbt retry` | Retry failed nodes from last run | Continue after failures | `dbt retry` |
| `dbt clone` | Clone models using zero-copy | Fast environment cloning | `dbt clone --state ./prod` |
| `dbt freshness` | Deprecated; use source freshness | Check source data age | `dbt source freshness` |

---

## Advanced Selection Syntax

### Selection Methods

| Syntax | Description | Example |
|--------|-------------|---------|
| `model_name` | Select specific model | `dbt run --select customers` |
| `+model_name` | Model and all parents | `dbt run --select +customers` |
| `model_name+` | Model and all children | `dbt run --select customers+` |
| `+model_name+` | Model, parents, and children | `dbt run --select +customers+` |
| `@model_name` | Model in different state | `dbt run --select @customers` |
| `tag:tag_name` | All models with tag | `dbt run --select tag:hourly` |
| `source:source_name` | All models from source | `dbt run --select source:raw_data` |
| `path:folder/` | All models in folder | `dbt run --select path:models/staging/` |
| `package:package_name` | All models in package | `dbt run --select package:dbt_utils` |
| `config.materialized:table` | Models with config | `dbt run --select config.materialized:table` |
| `state:modified` | Modified models | `dbt run --select state:modified` |
| `state:new` | Newly added models | `dbt run --select state:new` |
| `result:error` | Models that errored | `dbt test --select result:error` |
| `result:fail` | Models that failed | `dbt test --select result:fail` |

### Intersection and Union

| Syntax | Description | Example |
|--------|-------------|---------|
| `model1 model2` | Union (OR) | `dbt run --select model1 model2` |
| `tag:daily,tag:critical` | Intersection (AND) | `dbt run --select tag:daily,tag:critical` |
| `+model1 model2+` | Complex selection | `dbt run --select +staging_orders orders+` |

### Graph Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `n+` | n-levels downstream | `dbt run --select 2+customers` (2 levels up) |
| `+n` | n-levels upstream | `dbt run --select customers+2` (2 levels down) |
| `@` | At-operator for state | `dbt run --select @state:modified` |

---

## Common Workflow Patterns

### Development Workflow

```bash
# 1. Setup project
dbt deps
dbt debug

# 2. Develop and test
dbt run --select model_name
dbt test --select model_name
dbt compile --select model_name

# 3. Build downstream
dbt run --select model_name+
dbt test --select model_name+

# 4. Full build
dbt build
```

### Production Deployment

```bash
# 1. Run production build with tests
dbt build --target prod

# 2. Check source freshness
dbt source freshness --target prod

# 3. Create snapshots
dbt snapshot --target prod

# 4. Generate documentation
dbt docs generate --target prod
```

### CI/CD Pipeline

```bash
# 1. Install dependencies
dbt deps

# 2. Run modified models only
dbt run --select state:modified+ --defer --state ./prod

# 3. Test modified models
dbt test --select state:modified+ --defer --state ./prod

# 4. Check for failures
dbt build --fail-fast --select state:modified+
```

### Debugging Workflow

```bash
# 1. Check connection
dbt debug

# 2. Parse project
dbt parse

# 3. Compile SQL
dbt compile --select model_name --debug

# 4. Preview results
dbt show --select model_name

# 5. Run with debug
dbt run --select model_name --debug
```

---

## Environment-Specific Flags

### Development Flags

| Flag | Description | Example |
|------|-------------|---------|
| `--target dev` | Use dev target | `dbt run --target dev` |
| `--defer` | Use production for unbuilt refs | `dbt run --defer` |
| `--state ./target` | Point to state directory | `dbt run --state ./prod` |
| `--full-refresh` | Rebuild incremental models | `dbt run --full-refresh` |

### Production Flags

| Flag | Description | Example |
|------|-------------|---------|
| `--target prod` | Use production target | `dbt run --target prod` |
| `--threads 8` | Set thread count | `dbt run --threads 8` |
| `--fail-fast` | Stop on first failure | `dbt run --fail-fast` |
| `--store-failures` | Store test failures | `dbt test --store-failures` |

### Performance Flags

| Flag | Description | Example |
|------|-------------|---------|
| `--threads n` | Number of concurrent threads | `dbt run --threads 16` |
| `--partial-parse` | Enable partial parsing | `dbt run --partial-parse` |
| `--no-partial-parse` | Disable partial parsing | `dbt run --no-partial-parse` |
| `--use-experimental-parser` | Use faster parser | `dbt run --use-experimental-parser` |

---

## Best Practices Summary

### Development
- Use `--select` to run only what you need
- Use `state:modified+` for slim CI
- Use `dbt show` for quick data previews
- Use `--defer` to avoid rebuilding unchanged models

### Production
- Always use `--target prod` explicitly
- Use `dbt build` for comprehensive runs
- Set appropriate `--threads` based on warehouse
- Use `--fail-fast` for quick failure detection
- Schedule `dbt source freshness` checks

### Testing
- Run tests after every model change
- Use `--store-failures` to debug test failures
- Test sources separately from models
- Use tags to organize test execution

### Documentation
- Generate docs regularly
- Include column descriptions
- Use meta fields for additional context
- Host docs for team access

---

## Quick Reference by Frequency

### Daily Use
```bash
dbt run --select model_name
dbt test --select model_name
dbt build
dbt show --select model_name
```

### Weekly Use
```bash
dbt run --full-refresh
dbt snapshot
dbt docs generate
dbt source freshness
```

### Occasional Use
```bash
dbt deps
dbt clean
dbt debug
dbt run-operation macro_name
dbt retry
```

---

*Note: This reference is based on dbt Core 1.x commands. Always refer to [dbt documentation](https://docs.getdbt.com) for the most up-to-date information.*
