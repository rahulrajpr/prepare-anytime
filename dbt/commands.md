# 🎯 dbt Commands Reference Guide

<div align="center">

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Development](https://img.shields.io/badge/Development-4CAF50?style=for-the-badge)
![Production](https://img.shields.io/badge/Production-FF5722?style=for-the-badge)
![Testing](https://img.shields.io/badge/Testing-2196F3?style=for-the-badge)

</div>

A comprehensive guide to dbt (data build tool) commands organized by use case, environment, and workflow stage.

---

## 📑 Table of Contents

1. [🔧 Development Environment Commands](#-development-environment-commands)
2. [🚀 Production Environment Commands](#-production-environment-commands)
3. [✅ Testing & Quality Assurance](#-testing--quality-assurance)
4. [📚 Documentation Commands](#-documentation-commands)
5. [🐛 Debugging & Troubleshooting](#-debugging--troubleshooting)
6. [📦 Package Management](#-package-management)
7. [🏗️ Project Management](#️-project-management)
8. [🎯 Advanced Selection Syntax](#-advanced-selection-syntax)

---

## 🔧 Development Environment Commands

### Core Build Commands

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt run```** | Execute all models in your project | Full refresh of all models | ```bash<br/>dbt run<br/>``` |
| **```dbt run --select model_name```** | Run a specific model | Testing individual model changes | ```bash<br/>dbt run --select customers<br/>``` |
| **```dbt run --select model_name+```** | Run a model and all downstream models | Testing impact of changes | ```bash<br/>dbt run --select customers+<br/>``` |
| **```dbt run --select +model_name```** | Run a model and all upstream models | Ensuring dependencies are built | ```bash<br/>dbt run --select +orders<br/>``` |
| **```dbt run --select +model_name+```** | Run a model with all dependencies | Complete lineage execution | ```bash<br/>dbt run --select +dim_customers+<br/>``` |
| **```dbt run --select path/to/folder/```** | Run all models in a folder | Running models by directory | ```bash<br/>dbt run --select models/staging/<br/>``` |
| **```dbt run --select tag:daily```** | Run models with a specific tag | Tag-based execution | ```bash<br/>dbt run --select tag:daily<br/>``` |
| **```dbt run --exclude model_name```** | Run all models except specified | Skip problematic models | ```bash<br/>dbt run --exclude staging_orders<br/>``` |
| **```dbt run --full-refresh```** | Force rebuild incremental models | Reset incremental logic | ```bash<br/>dbt run --full-refresh<br/>``` |

### 🔄 Incremental Development

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt run --select state:modified```** | Run only modified models | Efficient development workflow | ```bash<br/>dbt run --select state:modified<br/>``` |
| **```dbt run --select state:modified+```** | Run modified models and downstream | Impact analysis after changes | ```bash<br/>dbt run --select state:modified+<br/>``` |
| **```dbt run --models @state:modified```** | Alternative syntax for modified | Slim CI workflows | ```bash<br/>dbt run --models @state:modified<br/>``` |
| **```dbt run --defer --state ./prod-run-artifacts```** | Compare against production state | Development without full build | ```bash<br/>dbt run --defer --state ./target<br/>``` |

### ⚡ Quick Iteration Commands

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt compile```** | Generate SQL without executing | Verify SQL compilation | ```bash<br/>dbt compile<br/>``` |
| **```dbt compile --select model_name```** | Compile specific model | Check individual model SQL | ```bash<br/>dbt compile --select customers<br/>``` |
| **```dbt show --select model_name```** | Preview model results (5 rows) | Quick data validation | ```bash<br/>dbt show --select customers<br/>``` |
| **```dbt show --inline "select * from {{ ref('customers') }}"```** | Run ad-hoc SQL query | Quick data exploration | ```bash<br/>dbt show --inline "select ..."<br/>``` |

---

## 🚀 Production Environment Commands

### 📅 Scheduled Production Runs

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt run --target prod```** | Run models in production target | Daily production refresh | ```bash<br/>dbt run --target prod<br/>``` |
| **```dbt run --target prod --select tag:daily```** | Run daily tagged models | Scheduled daily jobs | ```bash<br/>dbt run --target prod --select tag:daily<br/>``` |
| **```dbt run --target prod --select tag:hourly```** | Run hourly models | Frequent refresh models | ```bash<br/>dbt run --target prod --select tag:hourly<br/>``` |
| **```dbt run --target prod --full-refresh --select tag:weekly```** | Full refresh weekly models | Weekly full rebuild | ```bash<br/>dbt run --target prod --full-refresh --select tag:weekly<br/>``` |

### 🏗️ Production Build with Tests

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt build --target prod```** | Run, test, and snapshot all | Complete production build | ```bash<br/>dbt build --target prod<br/>``` |
| **```dbt build --select tag:critical```** | Build critical models with tests | High-priority pipeline | ```bash<br/>dbt build --select tag:critical<br/>``` |
| **```dbt build --exclude tag:experimental```** | Build excluding experimental | Stable production run | ```bash<br/>dbt build --exclude tag:experimental<br/>``` |

### 📸 Snapshot Management

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt snapshot```** | Create/update all snapshots | Capture SCD Type 2 changes | ```bash<br/>dbt snapshot<br/>``` |
| **```dbt snapshot --select snapshot_name```** | Run specific snapshot | Target specific SCD tables | ```bash<br/>dbt snapshot --select customer_snapshot<br/>``` |
| **```dbt snapshot --target prod```** | Run snapshots in production | Production data versioning | ```bash<br/>dbt snapshot --target prod<br/>``` |

### 🌱 Seed Data Management

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt seed```** | Load CSV files into warehouse | Load reference data | ```bash<br/>dbt seed<br/>``` |
| **```dbt seed --select seed_name```** | Load specific seed file | Update single reference table | ```bash<br/>dbt seed --select country_codes<br/>``` |
| **```dbt seed --full-refresh```** | Force reload all seeds | Reset seed data | ```bash<br/>dbt seed --full-refresh<br/>``` |
| **```dbt seed --target prod```** | Load seeds to production | Production seed deployment | ```bash<br/>dbt seed --target prod<br/>``` |

---

## ✅ Testing & Quality Assurance

### 🧪 Test Execution

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt test```** | Run all tests in project | Complete quality check | ```bash<br/>dbt test<br/>``` |
| **```dbt test --select model_name```** | Test specific model | Validate individual model | ```bash<br/>dbt test --select customers<br/>``` |
| **```dbt test --select test_type:generic```** | Run only generic tests | Schema validation | ```bash<br/>dbt test --select test_type:generic<br/>``` |
| **```dbt test --select test_type:singular```** | Run only singular tests | Custom business logic tests | ```bash<br/>dbt test --select test_type:singular<br/>``` |
| **```dbt test --select tag:critical```** | Test critical models only | High-priority validation | ```bash<br/>dbt test --select tag:critical<br/>``` |
| **```dbt test --select source:*```** | Test all source freshness | Validate source data | ```bash<br/>dbt test --select source:*<br/>``` |
| **```dbt test --store-failures```** | Save failing rows to warehouse | Debug test failures | ```bash<br/>dbt test --store-failures<br/>``` |

### 🕐 Source Freshness

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt source freshness```** | Check all source freshness | Validate data arrival | ```bash<br/>dbt source freshness<br/>``` |
| **```dbt source freshness --select source:source_name```** | Check specific source | Target source validation | ```bash<br/>dbt source freshness --select source:raw_data<br/>``` |
| **```dbt source freshness --output ./freshness.json```** | Output to JSON file | CI/CD integration | ```bash<br/>dbt source freshness --output ./freshness.json<br/>``` |

### 🔗 Combined Build and Test

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt build```** | Run models, tests, snapshots, seeds | Complete workflow execution | ```bash<br/>dbt build<br/>``` |
| **```dbt build --select +model_name+```** | Build with full lineage testing | End-to-end validation | ```bash<br/>dbt build --select +customers+<br/>``` |
| **```dbt build --fail-fast```** | Stop on first failure | Quick failure detection | ```bash<br/>dbt build --fail-fast<br/>``` |

---

## 📚 Documentation Commands

### 📝 Generate Documentation

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt docs generate```** | Generate documentation artifacts | Create project docs | ```bash<br/>dbt docs generate<br/>``` |
| **```dbt docs generate --target prod```** | Generate docs for prod target | Production documentation | ```bash<br/>dbt docs generate --target prod<br/>``` |
| **```dbt docs serve```** | Launch local documentation site | Browse docs locally | ```bash<br/>dbt docs serve<br/>``` |
| **```dbt docs serve --port 8001```** | Serve docs on custom port | Avoid port conflicts | ```bash<br/>dbt docs serve --port 8001<br/>``` |

---

## 🐛 Debugging & Troubleshooting

### 🔍 Debugging Commands

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt compile --select model_name```** | View compiled SQL | Debug SQL logic | ```bash<br/>dbt compile --select customers<br/>``` |
| **```dbt run-operation macro_name```** | Execute specific macro | Test macro logic | ```bash<br/>dbt run-operation grant_select<br/>``` |
| **```dbt run-operation macro_name --args '{key: value}'```** | Run macro with arguments | Parameterized macro testing | ```bash<br/>dbt run-operation create_schema --args '{schema: analytics}'<br/>``` |
| **```dbt ls```** | List all resources | Understand project structure | ```bash<br/>dbt ls<br/>``` |
| **```dbt ls --select model_name+```** | List model and downstream | Trace dependencies | ```bash<br/>dbt ls --select customers+<br/>``` |
| **```dbt ls --resource-type model```** | List all models | View all models | ```bash<br/>dbt ls --resource-type model<br/>``` |
| **```dbt ls --resource-type test```** | List all tests | View all tests | ```bash<br/>dbt ls --resource-type test<br/>``` |
| **```dbt ls --output json```** | Output as JSON | Programmatic access | ```bash<br/>dbt ls --output json<br/>``` |

### 📊 Logging and Verbosity

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt run --debug```** | Run with detailed debug logs | Troubleshoot issues | ```bash<br/>dbt run --debug<br/>``` |
| **```dbt run --log-level debug```** | Set log level explicitly | Control log verbosity | ```bash<br/>dbt run --log-level debug<br/>``` |
| **```dbt run --log-format json```** | Output logs as JSON | Machine-readable logs | ```bash<br/>dbt run --log-format json<br/>``` |
| **```dbt compile --no-version-check```** | Skip version check | Avoid version warnings | ```bash<br/>dbt compile --no-version-check<br/>``` |

### 🔧 Parse and Validate

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt parse```** | Parse project files | Validate project structure | ```bash<br/>dbt parse<br/>``` |
| **```dbt clean```** | Delete target/ and dbt_packages/ | Clean build artifacts | ```bash<br/>dbt clean<br/>``` |
| **```dbt debug```** | Test database connection | Diagnose connection issues | ```bash<br/>dbt debug<br/>``` |
| **```dbt debug --config-dir```** | Show configuration location | Find config files | ```bash<br/>dbt debug --config-dir<br/>``` |

---

## 📦 Package Management

### 📥 Package Commands

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt deps```** | Install packages from packages.yml | Setup project dependencies | ```bash<br/>dbt deps<br/>``` |
| **```dbt clean```** | Remove installed packages | Clean before fresh install | ```bash<br/>dbt clean<br/>``` |
| **```dbt deps && dbt run```** | Install deps and run | Fresh environment setup | ```bash<br/>dbt deps && dbt run<br/>``` |

---

## 🏗️ Project Management

### 🎬 Initialization and Setup

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt init project_name```** | Create new dbt project | Start new project | ```bash<br/>dbt init my_analytics<br/>``` |
| **```dbt init```** | Initialize in current directory | Setup existing project | ```bash<br/>dbt init<br/>``` |
| **```dbt debug```** | Verify connection setup | Initial configuration | ```bash<br/>dbt debug<br/>``` |

### ⚙️ Project Operations

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **```dbt retry```** | Retry failed nodes from last run | Continue after failures | ```bash<br/>dbt retry<br/>``` |
| **```dbt clone```** | Clone models using zero-copy | Fast environment cloning | ```bash<br/>dbt clone --state ./prod<br/>``` |
| **```dbt freshness```** | Deprecated; use source freshness | Check source data age | ```bash<br/>dbt source freshness<br/>``` |

---

## 🎯 Advanced Selection Syntax

### 🔍 Selection Methods

| Syntax | Description | Example |
|--------|-------------|---------|
| **```model_name```** | Select specific model | `dbt run --select customers` |
| **```+model_name```** | Model and all parents | `dbt run --select +customers` |
| **```model_name+```** | Model and all children | `dbt run --select customers+` |
| **```+model_name+```** | Model, parents, and children | `dbt run --select +customers+` |
| **```@model_name```** | Model in different state | `dbt run --select @customers` |
| **```tag:tag_name```** | All models with tag | `dbt run --select tag:hourly` |
| **```source:source_name```** | All models from source | `dbt run --select source:raw_data` |
| **```path:folder/```** | All models in folder | `dbt run --select path:models/staging/` |
| **```package:package_name```** | All models in package | `dbt run --select package:dbt_utils` |
| **```config.materialized:table```** | Models with config | `dbt run --select config.materialized:table` |
| **```state:modified```** | Modified models | `dbt run --select state:modified` |
| **```state:new```** | Newly added models | `dbt run --select state:new` |
| **```result:error```** | Models that errored | `dbt test --select result:error` |
| **```result:fail```** | Models that failed | `dbt test --select result:fail` |

### 🔀 Intersection and Union

| Syntax | Description | Example |
|--------|-------------|---------|
| **```model1 model2```** | Union (OR) | `dbt run --select model1 model2` |
| **```tag:daily,tag:critical```** | Intersection (AND) | `dbt run --select tag:daily,tag:critical` |
| **```+model1 model2+```** | Complex selection | `dbt run --select +staging_orders orders+` |

### 📊 Graph Operators

| Operator | Description | Example |
|----------|-------------|---------|
| **```n+```** | n-levels downstream | `dbt run --select 2+customers` (2 levels up) |
| **```+n```** | n-levels upstream | `dbt run --select customers+2` (2 levels down) |
| **```@```** | At-operator for state | `dbt run --select @state:modified` |

---

## 💼 Common Workflow Patterns

### 🔧 Development Workflow

```bash
# 1. Setup project
dbt deps                                    # 📦 Install dependencies
dbt debug                                   # 🔍 Verify connection

# 2. Develop and test
dbt run --select model_name                 # ▶️ Run specific model
dbt test --select model_name                # ✅ Test model
dbt compile --select model_name             # 🔨 Check SQL

# 3. Build downstream
dbt run --select model_name+                # ⬇️ Run with children
dbt test --select model_name+               # ✅ Test downstream

# 4. Full build
dbt build                                   # 🏗️ Complete build
```

### 🚀 Production Deployment

```bash
# 1. Run production build with tests
dbt build --target prod                     # 🎯 Full production build

# 2. Check source freshness
dbt source freshness --target prod          # 🕐 Validate sources

# 3. Create snapshots
dbt snapshot --target prod                  # 📸 SCD Type 2

# 4. Generate documentation
dbt docs generate --target prod             # 📚 Create docs
```

### 🔄 CI/CD Pipeline

```bash
# 1. Install dependencies
dbt deps                                    # 📦 Get packages

# 2. Run modified models only
dbt run --select state:modified+ --defer --state ./prod    # 🎯 Slim CI

# 3. Test modified models
dbt test --select state:modified+ --defer --state ./prod   # ✅ Test changes

# 4. Check for failures
dbt build --fail-fast --select state:modified+             # 🚨 Fast fail
```

### 🐛 Debugging Workflow

```bash
# 1. Check connection
dbt debug                                   # 🔌 Test connection

# 2. Parse project
dbt parse                                   # 📋 Validate structure

# 3. Compile SQL
dbt compile --select model_name --debug     # 🔍 Debug SQL

# 4. Preview results
dbt show --select model_name                # 👀 Quick preview

# 5. Run with debug
dbt run --select model_name --debug         # 🐛 Detailed logs
```

---

## 🎛️ Environment-Specific Flags

### 🔧 Development Flags

| Flag | Description | Example |
|------|-------------|---------|
| **```--target dev```** | Use dev target | `dbt run --target dev` |
| **```--defer```** | Use production for unbuilt refs | `dbt run --defer` |
| **```--state ./target```** | Point to state directory | `dbt run --state ./prod` |
| **```--full-refresh```** | Rebuild incremental models | `dbt run --full-refresh` |

### 🚀 Production Flags

| Flag | Description | Example |
|------|-------------|---------|
| **```--target prod```** | Use production target | `dbt run --target prod` |
| **```--threads 8```** | Set thread count | `dbt run --threads 8` |
| **```--fail-fast```** | Stop on first failure | `dbt run --fail-fast` |
| **```--store-failures```** | Store test failures | `dbt test --store-failures` |

### ⚡ Performance Flags

| Flag | Description | Example |
|------|-------------|---------|
| **```--threads n```** | Number of concurrent threads | `dbt run --threads 16` |
| **```--partial-parse```** | Enable partial parsing | `dbt run --partial-parse` |
| **```--no-partial-parse```** | Disable partial parsing | `dbt run --no-partial-parse` |
| **```--use-experimental-parser```** | Use faster parser | `dbt run --use-experimental-parser` |

---

## 🌟 Best Practices Summary

### 🔧 Development
- ✅ Use `--select` to run only what you need
- ✅ Use `state:modified+` for slim CI
- ✅ Use `dbt show` for quick data previews
- ✅ Use `--defer` to avoid rebuilding unchanged models

### 🚀 Production
- ✅ Always use `--target prod` explicitly
- ✅ Use `dbt build` for comprehensive runs
- ✅ Set appropriate `--threads` based on warehouse
- ✅ Use `--fail-fast` for quick failure detection
- ✅ Schedule `dbt source freshness` checks

### ✅ Testing
- ✅ Run tests after every model change
- ✅ Use `--store-failures` to debug test failures
- ✅ Test sources separately from models
- ✅ Use tags to organize test execution

### 📚 Documentation
- ✅ Generate docs regularly
- ✅ Include column descriptions
- ✅ Use meta fields for additional context
- ✅ Host docs for team access

---

## ⚡ Quick Reference by Frequency

### 🔥 Daily Use
```bash
dbt run --select model_name                 # 🎯 Run model
dbt test --select model_name                # ✅ Test model
dbt build                                   # 🏗️ Full build
dbt show --select model_name                # 👀 Preview
```

### 📅 Weekly Use
```bash
dbt run --full-refresh                      # 🔄 Full refresh
dbt snapshot                                # 📸 Snapshots
dbt docs generate                           # 📚 Docs
dbt source freshness                        # 🕐 Check sources
```

### 🔧 Occasional Use
```bash
dbt deps                                    # 📦 Dependencies
dbt clean                                   # 🧹 Clean
dbt debug                                   # 🔍 Debug
dbt run-operation macro_name                # ⚙️ Run macro
dbt retry                                   # 🔄 Retry
```

---

<div align="center">

### 🎓 Pro Tips

![Tip 1](https://img.shields.io/badge/💡_TIP-Use_tags_for_scheduling-FFEB3B?style=for-the-badge&logoColor=black)
![Tip 2](https://img.shields.io/badge/💡_TIP-Leverage_state:modified_in_CI-00BCD4?style=for-the-badge)
![Tip 3](https://img.shields.io/badge/💡_TIP-Store_failures_for_debugging-E91E63?style=for-the-badge)

</div>

---

*Note: This reference is based on dbt Core 1.x commands. Always refer to [dbt documentation](https://docs.getdbt.com) for the most up-to-date information.*

### 🔄 Incremental Development

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt run --select state:modified`** <br/> ![State Modified](https://img.shields.io/badge/State:Modified-00BCD4?style=flat-square) | Run only modified models | Efficient development workflow | ```bash<br/>dbt run --select state:modified<br/>``` |
| **`dbt run --select state:modified+`** <br/> ![Impact Analysis](https://img.shields.io/badge/Impact_Analysis-9C27B0?style=flat-square) | Run modified models and downstream | Impact analysis after changes | ```bash<br/>dbt run --select state:modified+<br/>``` |
| **`dbt run --models @state:modified`** <br/> ![Slim CI](https://img.shields.io/badge/Slim_CI-4CAF50?style=flat-square) | Alternative syntax for modified | Slim CI workflows | ```bash<br/>dbt run --models @state:modified<br/>``` |
| **`dbt run --defer --state ./prod-run-artifacts`** <br/> ![Defer](https://img.shields.io/badge/Defer-FF9800?style=flat-square) | Compare against production state | Development without full build | ```bash<br/>dbt run --defer --state ./target<br/>``` |

### ⚡ Quick Iteration Commands

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt compile`** <br/> ![Compile](https://img.shields.io/badge/Compile-2196F3?style=flat-square) | Generate SQL without executing | Verify SQL compilation | ```bash<br/>dbt compile<br/>``` |
| **`dbt compile --select model_name`** <br/> ![Single Compile](https://img.shields.io/badge/Single-3F51B5?style=flat-square) | Compile specific model | Check individual model SQL | ```bash<br/>dbt compile --select customers<br/>``` |
| **`dbt show --select model_name`** <br/> ![Preview](https://img.shields.io/badge/Preview-FF6F00?style=flat-square) | Preview model results (5 rows) | Quick data validation | ```bash<br/>dbt show --select customers<br/>``` |
| **`dbt show --inline "select * from {{ ref('customers') }}"`** <br/> ![Ad-hoc](https://img.shields.io/badge/Ad--hoc-E91E63?style=flat-square) | Run ad-hoc SQL query | Quick data exploration | ```bash<br/>dbt show --inline "select ..."<br/>``` |

---

## 🚀 Production Environment Commands

### 📅 Scheduled Production Runs

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt run --target prod`** <br/> ![Production](https://img.shields.io/badge/Production-FF5722?style=flat-square) | Run models in production target | Daily production refresh | ```bash<br/>dbt run --target prod<br/>``` |
| **`dbt run --target prod --select tag:daily`** <br/> ![Daily](https://img.shields.io/badge/Daily-4CAF50?style=flat-square) | Run daily tagged models | Scheduled daily jobs | ```bash<br/>dbt run --target prod --select tag:daily<br/>``` |
| **`dbt run --target prod --select tag:hourly`** <br/> ![Hourly](https://img.shields.io/badge/Hourly-FF9800?style=flat-square) | Run hourly models | Frequent refresh models | ```bash<br/>dbt run --target prod --select tag:hourly<br/>``` |
| **`dbt run --target prod --full-refresh --select tag:weekly`** <br/> ![Weekly](https://img.shields.io/badge/Weekly-9C27B0?style=flat-square) | Full refresh weekly models | Weekly full rebuild | ```bash<br/>dbt run --target prod --full-refresh --select tag:weekly<br/>``` |

### 🏗️ Production Build with Tests

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt build --target prod`** <br/> ![Build All](https://img.shields.io/badge/Build_All-FF5722?style=flat-square) | Run, test, and snapshot all | Complete production build | ```bash<br/>dbt build --target prod<br/>``` |
| **`dbt build --select tag:critical`** <br/> ![Critical](https://img.shields.io/badge/Critical-F44336?style=flat-square) | Build critical models with tests | High-priority pipeline | ```bash<br/>dbt build --select tag:critical<br/>``` |
| **`dbt build --exclude tag:experimental`** <br/> ![Stable](https://img.shields.io/badge/Stable-4CAF50?style=flat-square) | Build excluding experimental | Stable production run | ```bash<br/>dbt build --exclude tag:experimental<br/>``` |

### 📸 Snapshot Management

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt snapshot`** <br/> ![Snapshot All](https://img.shields.io/badge/Snapshot-673AB7?style=flat-square) | Create/update all snapshots | Capture SCD Type 2 changes | ```bash<br/>dbt snapshot<br/>``` |
| **`dbt snapshot --select snapshot_name`** <br/> ![Single Snapshot](https://img.shields.io/badge/Single-9C27B0?style=flat-square) | Run specific snapshot | Target specific SCD tables | ```bash<br/>dbt snapshot --select customer_snapshot<br/>``` |
| **`dbt snapshot --target prod`** <br/> ![Prod Snapshot](https://img.shields.io/badge/Production-FF5722?style=flat-square) | Run snapshots in production | Production data versioning | ```bash<br/>dbt snapshot --target prod<br/>``` |

### 🌱 Seed Data Management

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt seed`** <br/> ![Seed All](https://img.shields.io/badge/Seed-8BC34A?style=flat-square) | Load CSV files into warehouse | Load reference data | ```bash<br/>dbt seed<br/>``` |
| **`dbt seed --select seed_name`** <br/> ![Single Seed](https://img.shields.io/badge/Single-4CAF50?style=flat-square) | Load specific seed file | Update single reference table | ```bash<br/>dbt seed --select country_codes<br/>``` |
| **`dbt seed --full-refresh`** <br/> ![Refresh Seed](https://img.shields.io/badge/Refresh-FF9800?style=flat-square) | Force reload all seeds | Reset seed data | ```bash<br/>dbt seed --full-refresh<br/>``` |
| **`dbt seed --target prod`** <br/> ![Prod Seed](https://img.shields.io/badge/Production-FF5722?style=flat-square) | Load seeds to production | Production seed deployment | ```bash<br/>dbt seed --target prod<br/>``` |

---

## ✅ Testing & Quality Assurance

### 🧪 Test Execution

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt test`** <br/> ![Test All](https://img.shields.io/badge/Test_All-2196F3?style=flat-square) | Run all tests in project | Complete quality check | ```bash<br/>dbt test<br/>``` |
| **`dbt test --select model_name`** <br/> ![Single Test](https://img.shields.io/badge/Single-3F51B5?style=flat-square) | Test specific model | Validate individual model | ```bash<br/>dbt test --select customers<br/>``` |
| **`dbt test --select test_type:generic`** <br/> ![Generic](https://img.shields.io/badge/Generic-00BCD4?style=flat-square) | Run only generic tests | Schema validation | ```bash<br/>dbt test --select test_type:generic<br/>``` |
| **`dbt test --select test_type:singular`** <br/> ![Singular](https://img.shields.io/badge/Singular-9C27B0?style=flat-square) | Run only singular tests | Custom business logic tests | ```bash<br/>dbt test --select test_type:singular<br/>``` |
| **`dbt test --select tag:critical`** <br/> ![Critical](https://img.shields.io/badge/Critical-F44336?style=flat-square) | Test critical models only | High-priority validation | ```bash<br/>dbt test --select tag:critical<br/>``` |
| **`dbt test --select source:*`** <br/> ![Source](https://img.shields.io/badge/Source-FF6F00?style=flat-square) | Test all source freshness | Validate source data | ```bash<br/>dbt test --select source:*<br/>``` |
| **`dbt test --store-failures`** <br/> ![Store Failures](https://img.shields.io/badge/Store_Failures-E91E63?style=flat-square) | Save failing rows to warehouse | Debug test failures | ```bash<br/>dbt test --store-failures<br/>``` |

### 🕐 Source Freshness

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt source freshness`** <br/> ![Freshness All](https://img.shields.io/badge/Freshness-00BCD4?style=flat-square) | Check all source freshness | Validate data arrival | ```bash<br/>dbt source freshness<br/>``` |
| **`dbt source freshness --select source:source_name`** <br/> ![Single Source](https://img.shields.io/badge/Single_Source-0097A7?style=flat-square) | Check specific source | Target source validation | ```bash<br/>dbt source freshness --select source:raw_data<br/>``` |
| **`dbt source freshness --output ./freshness.json`** <br/> ![JSON Output](https://img.shields.io/badge/JSON-FF6F00?style=flat-square) | Output to JSON file | CI/CD integration | ```bash<br/>dbt source freshness --output ./freshness.json<br/>``` |

### 🔗 Combined Build and Test

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt build`** <br/> ![Build Complete](https://img.shields.io/badge/Build_Complete-4CAF50?style=flat-square) | Run models, tests, snapshots, seeds | Complete workflow execution | ```bash<br/>dbt build<br/>``` |
| **`dbt build --select +model_name+`** <br/> ![Full Lineage](https://img.shields.io/badge/Full_Lineage-9C27B0?style=flat-square) | Build with full lineage testing | End-to-end validation | ```bash<br/>dbt build --select +customers+<br/>``` |
| **`dbt build --fail-fast`** <br/> ![Fail Fast](https://img.shields.io/badge/Fail_Fast-F44336?style=flat-square) | Stop on first failure | Quick failure detection | ```bash<br/>dbt build --fail-fast<br/>``` |

---

## 📚 Documentation Commands

### 📝 Generate Documentation

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt docs generate`** <br/> ![Generate Docs](https://img.shields.io/badge/Generate-3F51B5?style=flat-square) | Generate documentation artifacts | Create project docs | ```bash<br/>dbt docs generate<br/>``` |
| **`dbt docs generate --target prod`** <br/> ![Prod Docs](https://img.shields.io/badge/Production-FF5722?style=flat-square) | Generate docs for prod target | Production documentation | ```bash<br/>dbt docs generate --target prod<br/>``` |
| **`dbt docs serve`** <br/> ![Serve Docs](https://img.shields.io/badge/Serve-2196F3?style=flat-square) | Launch local documentation site | Browse docs locally | ```bash<br/>dbt docs serve<br/>``` |
| **`dbt docs serve --port 8001`** <br/> ![Custom Port](https://img.shields.io/badge/Custom_Port-00BCD4?style=flat-square) | Serve docs on custom port | Avoid port conflicts | ```bash<br/>dbt docs serve --port 8001<br/>``` |

---

## 🐛 Debugging & Troubleshooting

### 🔍 Debugging Commands

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt compile --select model_name`** <br/> ![Compile](https://img.shields.io/badge/Compile-2196F3?style=flat-square) | View compiled SQL | Debug SQL logic | ```bash<br/>dbt compile --select customers<br/>``` |
| **`dbt run-operation macro_name`** <br/> ![Macro](https://img.shields.io/badge/Macro-9C27B0?style=flat-square) | Execute specific macro | Test macro logic | ```bash<br/>dbt run-operation grant_select<br/>``` |
| **`dbt run-operation macro_name --args '{key: value}'`** <br/> ![Args](https://img.shields.io/badge/With_Args-673AB7?style=flat-square) | Run macro with arguments | Parameterized macro testing | ```bash<br/>dbt run-operation create_schema --args '{schema: analytics}'<br/>``` |
| **`dbt ls`** <br/> ![List](https://img.shields.io/badge/List-00BCD4?style=flat-square) | List all resources | Understand project structure | ```bash<br/>dbt ls<br/>``` |
| **`dbt ls --select model_name+`** <br/> ![Dependencies](https://img.shields.io/badge/Dependencies-FF9800?style=flat-square) | List model and downstream | Trace dependencies | ```bash<br/>dbt ls --select customers+<br/>``` |
| **`dbt ls --resource-type model`** <br/> ![Models Only](https://img.shields.io/badge/Models-4CAF50?style=flat-square) | List all models | View all models | ```bash<br/>dbt ls --resource-type model<br/>``` |
| **`dbt ls --resource-type test`** <br/> ![Tests Only](https://img.shields.io/badge/Tests-2196F3?style=flat-square) | List all tests | View all tests | ```bash<br/>dbt ls --resource-type test<br/>``` |
| **`dbt ls --output json`** <br/> ![JSON](https://img.shields.io/badge/JSON-FF6F00?style=flat-square) | Output as JSON | Programmatic access | ```bash<br/>dbt ls --output json<br/>``` |

### 📊 Logging and Verbosity

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt run --debug`** <br/> ![Debug](https://img.shields.io/badge/Debug-F44336?style=flat-square) | Run with detailed debug logs | Troubleshoot issues | ```bash<br/>dbt run --debug<br/>``` |
| **`dbt run --log-level debug`** <br/> ![Log Level](https://img.shields.io/badge/Log_Level-FF5722?style=flat-square) | Set log level explicitly | Control log verbosity | ```bash<br/>dbt run --log-level debug<br/>``` |
| **`dbt run --log-format json`** <br/> ![JSON Logs](https://img.shields.io/badge/JSON_Logs-FF6F00?style=flat-square) | Output logs as JSON | Machine-readable logs | ```bash<br/>dbt run --log-format json<br/>``` |
| **`dbt compile --no-version-check`** <br/> ![No Version](https://img.shields.io/badge/No_Version-9E9E9E?style=flat-square) | Skip version check | Avoid version warnings | ```bash<br/>dbt compile --no-version-check<br/>``` |

### 🔧 Parse and Validate

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt parse`** <br/> ![Parse](https://img.shields.io/badge/Parse-3F51B5?style=flat-square) | Parse project files | Validate project structure | ```bash<br/>dbt parse<br/>``` |
| **`dbt clean`** <br/> ![Clean](https://img.shields.io/badge/Clean-607D8B?style=flat-square) | Delete target/ and dbt_packages/ | Clean build artifacts | ```bash<br/>dbt clean<br/>``` |
| **`dbt debug`** <br/> ![Debug](https://img.shields.io/badge/Debug-F44336?style=flat-square) | Test database connection | Diagnose connection issues | ```bash<br/>dbt debug<br/>``` |
| **`dbt debug --config-dir`** <br/> ![Config](https://img.shields.io/badge/Config-00BCD4?style=flat-square) | Show configuration location | Find config files | ```bash<br/>dbt debug --config-dir<br/>``` |

---

## 📦 Package Management

### 📥 Package Commands

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt deps`** <br/> ![Dependencies](https://img.shields.io/badge/Dependencies-4CAF50?style=flat-square) | Install packages from packages.yml | Setup project dependencies | ```bash<br/>dbt deps<br/>``` |
| **`dbt clean`** <br/> ![Clean](https://img.shields.io/badge/Clean-607D8B?style=flat-square) | Remove installed packages | Clean before fresh install | ```bash<br/>dbt clean<br/>``` |
| **`dbt deps && dbt run`** <br/> ![Chain](https://img.shields.io/badge/Chain-FF9800?style=flat-square) | Install deps and run | Fresh environment setup | ```bash<br/>dbt deps && dbt run<br/>``` |

---

## 🏗️ Project Management

### 🎬 Initialization and Setup

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt init project_name`** <br/> ![Init New](https://img.shields.io/badge/Init_New-4CAF50?style=flat-square) | Create new dbt project | Start new project | ```bash<br/>dbt init my_analytics<br/>``` |
| **`dbt init`** <br/> ![Init Current](https://img.shields.io/badge/Init_Current-8BC34A?style=flat-square) | Initialize in current directory | Setup existing project | ```bash<br/>dbt init<br/>``` |
| **`dbt debug`** <br/> ![Verify](https://img.shields.io/badge/Verify-2196F3?style=flat-square) | Verify connection setup | Initial configuration | ```bash<br/>dbt debug<br/>``` |

### ⚙️ Project Operations

| Command | Description | Use Case | Example |
|---------|-------------|----------|---------|
| **`dbt retry`** <br/> ![Retry](https://img.shields.io/badge/Retry-FF9800?style=flat-square) | Retry failed nodes from last run | Continue after failures | ```bash<br/>dbt retry<br/>``` |
| **`dbt clone`** <br/> ![Clone](https://img.shields.io/badge/Clone-9C27B0?style=flat-square) | Clone models using zero-copy | Fast environment cloning | ```bash<br/>dbt clone --state ./prod<br/>``` |
| **`dbt freshness`** <br/> ![Deprecated](https://img.shields.io/badge/Deprecated-F44336?style=flat-square) | Deprecated; use source freshness | Check source data age | ```bash<br/>dbt source freshness<br/>``` |

---

## 🎯 Advanced Selection Syntax

### 🔍 Selection Methods

| Syntax | Description | Example |
|--------|-------------|---------|
| **`model_name`** <br/> ![Direct](https://img.shields.io/badge/Direct-4CAF50?style=flat-square) | Select specific model | `dbt run --select customers` |
| **`+model_name`** <br/> ![Parents](https://img.shields.io/badge/Parents-3F51B5?style=flat-square) | Model and all parents | `dbt run --select +customers` |
| **`model_name+`** <br/> ![Children](https://img.shields.io/badge/Children-9C27B0?style=flat-square) | Model and all children | `dbt run --select customers+` |
| **`+model_name+`** <br/> ![Full Graph](https://img.shields.io/badge/Full_Graph-E91E63?style=flat-square) | Model, parents, and children | `dbt run --select +customers+` |
| **`@model_name`** <br/> ![At State](https://img.shields.io/badge/At_State-00BCD4?style=flat-square) | Model in different state | `dbt run --select @customers` |
| **`tag:tag_name`** <br/> ![Tag](https://img.shields.io/badge/Tag-FFEB3B?style=flat-square&logoColor=black&color=FFEB3B) | All models with tag | `dbt run --select tag:hourly` |
| **`source:source_name`** <br/> ![Source](https://img.shields.io/badge/Source-FF6F00?style=flat-square) | All models from source | `dbt run --select source:raw_data` |
| **`path:folder/`** <br/> ![Path](https://img.shields.io/badge/Path-00BCD4?style=flat-square) | All models in folder | `dbt run --select path:models/staging/` |
| **`package:package_name`** <br/> ![Package](https://img.shields.io/badge/Package-673AB7?style=flat-square) | All models in package | `dbt run --select package:dbt_utils` |
| **`config.materialized:table`** <br/> ![Config](https://img.shields.io/badge/Config-FF9800?style=flat-square) | Models with config | `dbt run --select config.materialized:table` |
| **`state:modified`** <br/> ![Modified](https://img.shields.io/badge/Modified-00BCD4?style=flat-square) | Modified models | `dbt run --select state:modified` |
| **`state:new`** <br/> ![New](https://img.shields.io/badge/New-4CAF50?style=flat-square) | Newly added models | `dbt run --select state:new` |
| **`result:error`** <br/> ![Error](https://img.shields.io/badge/Error-F44336?style=flat-square) | Models that errored | `dbt test --select result:error` |
| **`result:fail`** <br/> ![Fail](https://img.shields.io/badge/Fail-FF5722?style=flat-square) | Models that failed | `dbt test --select result:fail` |

### 🔀 Intersection and Union

| Syntax | Description | Example |
|--------|-------------|---------|
| **`model1 model2`** <br/> ![Union](https://img.shields.io/badge/Union_(OR)-9C27B0?style=flat-square) | Union (OR) | `dbt run --select model1 model2` |
| **`tag:daily,tag:critical`** <br/> ![Intersection](https://img.shields.io/badge/Intersection_(AND)-E91E63?style=flat-square) | Intersection (AND) | `dbt run --select tag:daily,tag:critical` |
| **`+model1 model2+`** <br/> ![Complex](https://img.shields.io/badge/Complex-FF6F00?style=flat-square) | Complex selection | `dbt run --select +staging_orders orders+` |

### 📊 Graph Operators

| Operator | Description | Example |
|----------|-------------|---------|
| **`n+`** <br/> ![N Upstream](https://img.shields.io/badge/N_Upstream-3F51B5?style=flat-square) | n-levels downstream | `dbt run --select 2+customers` (2 levels up) |
| **`+n`** <br/> ![N Downstream](https://img.shields.io/badge/N_Downstream-9C27B0?style=flat-square) | n-levels upstream | `dbt run --select customers+2` (2 levels down) |
| **`@`** <br/> ![At Operator](https://img.shields.io/badge/At_Operator-00BCD4?style=flat-square) | At-operator for state | `dbt run --select @state:modified` |

---

## 💼 Common Workflow Patterns

### 🔧 Development Workflow

```bash
# 1. Setup project
dbt deps                                    # 📦 Install dependencies
dbt debug                                   # 🔍 Verify connection

# 2. Develop and test
dbt run --select model_name                 # ▶️ Run specific model
dbt test --select model_name                # ✅ Test model
dbt compile --select model_name             # 🔨 Check SQL

# 3. Build downstream
dbt run --select model_name+                # ⬇️ Run with children
dbt test --select model_name+               # ✅ Test downstream

# 4. Full build
dbt build                                   # 🏗️ Complete build
```

### 🚀 Production Deployment

```bash
# 1. Run production build with tests
dbt build --target prod                     # 🎯 Full production build

# 2. Check source freshness
dbt source freshness --target prod          # 🕐 Validate sources

# 3. Create snapshots
dbt snapshot --target prod                  # 📸 SCD Type 2

# 4. Generate documentation
dbt docs generate --target prod             # 📚 Create docs
```

### 🔄 CI/CD Pipeline

```bash
# 1. Install dependencies
dbt deps                                    # 📦 Get packages

# 2. Run modified models only
dbt run --select state:modified+ --defer --state ./prod    # 🎯 Slim CI

# 3. Test modified models
dbt test --select state:modified+ --defer --state ./prod   # ✅ Test changes

# 4. Check for failures
dbt build --fail-fast --select state:modified+             # 🚨 Fast fail
```

### 🐛 Debugging Workflow

```bash
# 1. Check connection
dbt debug                                   # 🔌 Test connection

# 2. Parse project
dbt parse                                   # 📋 Validate structure

# 3. Compile SQL
dbt compile --select model_name --debug     # 🔍 Debug SQL

# 4. Preview results
dbt show --select model_name                # 👀 Quick preview

# 5. Run with debug
dbt run --select model_name --debug         # 🐛 Detailed logs
```

---

## 🎛️ Environment-Specific Flags

### 🔧 Development Flags

| Flag | Description | Example |
|------|-------------|---------|
| **`--target dev`** <br/> ![Dev](https://img.shields.io/badge/Dev-4CAF50?style=flat-square) | Use dev target | `dbt run --target dev` |
| **`--defer`** <br/> ![Defer](https://img.shields.io/badge/Defer-FF9800?style=flat-square) | Use production for unbuilt refs | `dbt run --defer` |
| **`--state ./target`** <br/> ![State](https://img.shields.io/badge/State-00BCD4?style=flat-square) | Point to state directory | `dbt run --state ./prod` |
| **`--full-refresh`** <br/> ![Refresh](https://img.shields.io/badge/Full_Refresh-FF5722?style=flat-square) | Rebuild incremental models | `dbt run --full-refresh` |

### 🚀 Production Flags

| Flag | Description | Example |
|------|-------------|---------|
| **`--target prod`** <br/> ![Production](https://img.shields.io/badge/Production-FF5722?style=flat-square) | Use production target | `dbt run --target prod` |
| **`--threads 8`** <br/> ![Threads](https://img.shields.io/badge/Threads-9C27B0?style=flat-square) | Set thread count | `dbt run --threads 8` |
| **`--fail-fast`** <br/> ![Fail Fast](https://img.shields.io/badge/Fail_Fast-F44336?style=flat-square) | Stop on first failure | `dbt run --fail-fast` |
| **`--store-failures`** <br/> ![Store](https://img.shields.io/badge/Store_Failures-E91E63?style=flat-square) | Store test failures | `dbt test --store-failures` |

### ⚡ Performance Flags

| Flag | Description | Example |
|------|-------------|---------|
| **`--threads n`** <br/> ![Threads](https://img.shields.io/badge/Threads-9C27B0?style=flat-square) | Number of concurrent threads | `dbt run --threads 16` |
| **`--partial-parse`** <br/> ![Parse](https://img.shields.io/badge/Partial_Parse-4CAF50?style=flat-square) | Enable partial parsing | `dbt run --partial-parse` |
| **`--no-partial-parse`** <br/> ![No Parse](https://img.shields.io/badge/No_Partial-F44336?style=flat-square) | Disable partial parsing | `dbt run --no-partial-parse` |
| **`--use-experimental-parser`** <br/> ![Experimental](https://img.shields.io/badge/Experimental-FF9800?style=flat-square) | Use faster parser | `dbt run --use-experimental-parser` |

---

## 🌟 Best Practices Summary

### 🔧 Development
- ✅ Use `--select` to run only what you need
- ✅ Use `state:modified+` for slim CI
- ✅ Use `dbt show` for quick data previews
- ✅ Use `--defer` to avoid rebuilding unchanged models

### 🚀 Production
- ✅ Always use `--target prod` explicitly
- ✅ Use `dbt build` for comprehensive runs
- ✅ Set appropriate `--threads` based on warehouse
- ✅ Use `--fail-fast` for quick failure detection
- ✅ Schedule `dbt source freshness` checks

### ✅ Testing
- ✅ Run tests after every model change
- ✅ Use `--store-failures` to debug test failures
- ✅ Test sources separately from models
- ✅ Use tags to organize test execution

### 📚 Documentation
- ✅ Generate docs regularly
- ✅ Include column descriptions
- ✅ Use meta fields for additional context
- ✅ Host docs for team access

---

## ⚡ Quick Reference by Frequency

### 🔥 Daily Use
```bash
dbt run --select model_name                 # 🎯 Run model
dbt test --select model_name                # ✅ Test model
dbt build                                   # 🏗️ Full build
dbt show --select model_name                # 👀 Preview
```

### 📅 Weekly Use
```bash
dbt run --full-refresh                      # 🔄 Full refresh
dbt snapshot                                # 📸 Snapshots
dbt docs generate                           # 📚 Docs
dbt source freshness                        # 🕐 Check sources
```

### 🔧 Occasional Use
```bash
dbt deps                                    # 📦 Dependencies
dbt clean                                   # 🧹 Clean
dbt debug                                   # 🔍 Debug
dbt run-operation macro_name                # ⚙️ Run macro
dbt retry                                   # 🔄 Retry
```

---

<div align="center">

### 🎓 Pro Tips

![Tip 1](https://img.shields.io/badge/💡_TIP-Use_tags_for_scheduling-FFEB3B?style=for-the-badge&logoColor=black)
![Tip 2](https://img.shields.io/badge/💡_TIP-Leverage_state:modified_in_CI-00BCD4?style=for-the-badge)
![Tip 3](https://img.shields.io/badge/💡_TIP-Store_failures_for_debugging-E91E63?style=for-the-badge)

</div>

---

*Note: This reference is based on dbt Core 1.x commands. Always refer to [dbt documentation](https://docs.getdbt.com) for the most up-to-date information.*
