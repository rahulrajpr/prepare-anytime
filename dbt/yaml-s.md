# 🎯 dbt YAML Files Guide

<div align="center">

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-CB171E?style=for-the-badge&logo=yaml&logoColor=white)
![Configuration](https://img.shields.io/badge/Configuration-4CAF50?style=for-the-badge)

</div>

A comprehensive guide to dbt YAML files - configuration, documentation, and testing in your dbt project.

---

## 📑 Table of Contents

1. [🔍 What are YAML Files in dbt?](#-what-are-yaml-files-in-dbt)
2. [📁 Core YAML Files](#-core-yaml-files)
3. [🔌 Profile Configuration (profiles.yml)](#-profile-configuration-profilesyml)
4. [⚙️ Project Configuration (dbt_project.yml)](#️-project-configuration-dbt_projectyml)
5. [📊 Properties Files (schema.yml / properties.yml)](#-properties-files-schemayml--propertiesyml)
6. [📦 Package Configuration (packages.yml)](#-package-configuration-packagesyml)
7. [🔗 Sources Configuration (sources.yml)](#-sources-configuration-sourcesyml)
8. [🎯 Selectors Configuration (selectors.yml)](#-selectors-configuration-selectorsyml)
9. [💡 Best Practices](#-best-practices)
10. [📝 Complete Examples](#-complete-examples)

---

## 🔍 What are YAML Files in dbt?

**YAML files** in dbt serve multiple purposes:
- 📖 **Documentation** - Describe models, columns, and data
- ✅ **Testing** - Define data quality tests
- ⚙️ **Configuration** - Set project-wide and model-specific configs
- 🔗 **Source definitions** - Document source tables
- 📊 **Exposures & Metrics** - Define downstream dependencies

### Key YAML Files in dbt

| File | Purpose | Location |
|------|---------|----------|
| **```profiles.yml```** | Database connection credentials | `~/.dbt/` (user home) or project root |
| **```dbt_project.yml```** | Project configuration, global settings | Root directory |
| **```schema.yml```** / **```properties.yml```** | Model/source documentation, tests | Any models folder |
| **```sources.yml```** / **```_sources.yml```** | Source table definitions | staging/ folders |
| **```packages.yml```** | Package dependencies | Root directory |
| **```selectors.yml```** | Custom selection logic | Root directory |
| **```dependencies.yml```** | Modern package management | Root directory |

---

## 🔌 Profile Configuration (profiles.yml)

### What is profiles.yml?

**```profiles.yml```** contains database connection credentials and configurations. It's kept separate from your project code for security.

**Location:**
- **Default**: `~/.dbt/profiles.yml` (user home directory)
- **Alternative**: Project root (not recommended for credentials)
- **Override**: Use `--profiles-dir` flag to specify custom location

### Basic Profile Structure

```yaml
# ~/.dbt/profiles.yml

my_profile_name:
  target: dev  # Default target to use
  
  outputs:
    dev:
      type: snowflake
      account: abc123.us-east-1
      user: dbt_user_dev
      password: "{{ env_var('DBT_PASSWORD') }}"
      role: transformer
      database: analytics_dev
      warehouse: transforming
      schema: dbt_{{ env_var('DBT_USER') }}
      threads: 4
    
    prod:
      type: snowflake
      account: abc123.us-east-1
      user: dbt_user_prod
      password: "{{ env_var('DBT_PROD_PASSWORD') }}"
      role: transformer
      database: analytics_prod
      warehouse: transforming_xl
      schema: analytics
      threads: 8
```

### Warehouse-Specific Profiles

#### Snowflake

```yaml
my_snowflake_profile:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: abc123.us-east-1  # Or abc123.snowflakecomputing.com
      user: dbt_user
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      
      # Authentication options (choose one):
      # Option 1: Password (shown above)
      # Option 2: Private key authentication
      # private_key_path: /path/to/private_key.p8
      # private_key_passphrase: "{{ env_var('SNOWFLAKE_PRIVATE_KEY_PASSPHRASE') }}"
      # Option 3: SSO authentication
      # authenticator: externalbrowser
      
      role: transformer
      database: analytics
      warehouse: transforming
      schema: dbt_{{ env_var('USER') }}
      threads: 4
      
      # Optional settings
      client_session_keep_alive: true
      query_tag: dbt_run
      connect_retries: 3
      connect_timeout: 10
      retry_on_database_errors: true
```

#### BigQuery

```yaml
my_bigquery_profile:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: my-gcp-project
      dataset: dbt_dev  # This will be your default schema
      
      # Authentication methods:
      # Option 1: Service account key file
      keyfile: /path/to/service-account.json
      
      # Option 2: OAuth
      # method: oauth
      
      threads: 4
      
      # Optional settings
      location: US  # or EU, asia-northeast1, etc.
      timeout_seconds: 300
      priority: interactive  # or batch
      retries: 1
      maximum_bytes_billed: 1000000000  # 1GB limit
      
      # Advanced settings
      execution_project: my-execution-project  # If different from project
      impersonate_service_account: sa@project.iam.gserviceaccount.com
```

#### Redshift

```yaml
my_redshift_profile:
  target: dev
  outputs:
    dev:
      type: redshift
      host: my-redshift-cluster.abc123.us-east-1.redshift.amazonaws.com
      user: dbt_user
      password: "{{ env_var('REDSHIFT_PASSWORD') }}"
      port: 5439
      dbname: analytics
      schema: dbt_dev
      threads: 4
      
      # Optional settings
      keepalives_idle: 240
      connect_timeout: 10
      ra3_node: true  # For RA3 node types
      sslmode: prefer  # or require, verify-ca, verify-full
      
      # IAM Authentication (alternative)
      # method: iam
      # cluster_id: my-redshift-cluster
      # region: us-east-1
      # iam_profile: default
```

#### Postgres

```yaml
my_postgres_profile:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      user: dbt_user
      password: "{{ env_var('POSTGRES_PASSWORD') }}"
      port: 5432
      dbname: analytics
      schema: dbt_dev
      threads: 4
      
      # Optional settings
      keepalives_idle: 0
      connect_timeout: 10
      retries: 1
      search_path: public
      role: dbt_role
      sslmode: prefer  # or disable, require
```

#### Databricks

```yaml
my_databricks_profile:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: main  # Unity Catalog (optional)
      schema: dbt_dev
      
      # Connection details
      host: abc-123456-xyz.cloud.databricks.com
      http_path: /sql/1.0/warehouses/abc123xyz
      token: "{{ env_var('DATABRICKS_TOKEN') }}"
      
      threads: 4
      
      # Optional settings
      connect_retries: 3
      connect_timeout: 10
```

#### DuckDB (Local Development)

```yaml
my_duckdb_profile:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'dev.duckdb'  # Path to database file
      schema: main
      threads: 4
      
      # Optional extensions
      extensions:
        - httpfs
        - parquet
```

### Environment Variables

**Using environment variables for security:**

```yaml
my_profile:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('SNOWFLAKE_USER') }}"
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      role: "{{ env_var('SNOWFLAKE_ROLE', 'transformer') }}"  # With default
      database: analytics
      warehouse: transforming
      schema: dbt_dev
      threads: 4
```

**Setting environment variables:**

```bash
# Linux/Mac
export SNOWFLAKE_ACCOUNT=abc123
export SNOWFLAKE_USER=dbt_user
export SNOWFLAKE_PASSWORD=my_password

# Windows
set SNOWFLAKE_ACCOUNT=abc123
set SNOWFLAKE_USER=dbt_user
set SNOWFLAKE_PASSWORD=my_password

# .env file (with python-dotenv)
SNOWFLAKE_ACCOUNT=abc123
SNOWFLAKE_USER=dbt_user
SNOWFLAKE_PASSWORD=my_password
```

### Multiple Targets

```yaml
my_profile:
  target: dev  # Default target
  
  outputs:
    # Development
    dev:
      type: snowflake
      account: abc123
      user: "{{ env_var('USER') }}"
      password: "{{ env_var('DEV_PASSWORD') }}"
      database: analytics_dev
      warehouse: transforming_xs
      schema: "dbt_{{ env_var('USER') }}"
      threads: 4
    
    # Continuous Integration
    ci:
      type: snowflake
      account: abc123
      user: dbt_ci_user
      password: "{{ env_var('CI_PASSWORD') }}"
      database: analytics_ci
      warehouse: transforming_xs
      schema: dbt_ci_{{ env_var('GITHUB_SHA', 'manual') }}
      threads: 4
    
    # Staging
    staging:
      type: snowflake
      account: abc123
      user: dbt_staging_user
      password: "{{ env_var('STAGING_PASSWORD') }}"
      database: analytics_staging
      warehouse: transforming_m
      schema: analytics
      threads: 6
    
    # Production
    prod:
      type: snowflake
      account: abc123
      user: dbt_prod_user
      password: "{{ env_var('PROD_PASSWORD') }}"
      database: analytics_prod
      warehouse: transforming_xl
      schema: analytics
      threads: 8
```

**Running specific target:**

```bash
# Use dev (default)
dbt run

# Use production
dbt run --target prod

# Use CI
dbt run --target ci

# Use staging
dbt run --target staging
```

### Profile Best Practices

#### 1. Security

```yaml
# ❌ WRONG - Hardcoded credentials
outputs:
  dev:
    type: snowflake
    password: mysecretpassword123

# ✅ CORRECT - Environment variables
outputs:
  dev:
    type: snowflake
    password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
```

#### 2. Dynamic Schemas

```yaml
# ✅ Personal dev schemas
outputs:
  dev:
    schema: "dbt_{{ env_var('USER') }}"  # Creates dbt_john, dbt_jane, etc.

# ✅ CI schemas with run identifier
outputs:
  ci:
    schema: "dbt_ci_{{ env_var('CIRCLE_BUILD_NUM', 'manual') }}"
```

#### 3. Thread Configuration

```yaml
outputs:
  dev:
    threads: 4  # Small for local development
  
  ci:
    threads: 4  # Moderate for CI
  
  prod:
    threads: 8  # Large for production
```

#### 4. Multiple Profiles in One File

```yaml
# ~/.dbt/profiles.yml

# Project 1
ecommerce:
  target: dev
  outputs:
    dev:
      type: snowflake
      # ... config

# Project 2
marketing:
  target: dev
  outputs:
    dev:
      type: bigquery
      # ... config

# Project 3
finance:
  target: prod
  outputs:
    prod:
      type: redshift
      # ... config
```

### Profile Commands

```bash
# Test connection
dbt debug

# Show active profile
dbt debug --config-dir

# Use specific profiles directory
dbt run --profiles-dir /path/to/profiles

# Use specific profile
dbt run --profile my_profile_name

# Use specific target
dbt run --target prod
```

### Profile Validation

**Check your profile configuration:**

```bash
# Validate connection
dbt debug

# Expected output:
# Configuration:
#   profiles.yml file [OK found and valid]
#   dbt_project.yml file [OK found and valid]
# 
# Required dependencies:
#  - git [OK found]
# 
# Connection:
#   account: abc123
#   user: dbt_user
#   database: analytics
#   schema: dbt_dev
#   warehouse: transforming
#   role: transformer
#   Connection test: [OK connection ok]
```

---

## 📁 Core YAML Files

### 1. 📋 dbt_project.yml (Project Configuration)

**Location**: Project root directory  
**Purpose**: Define project-level configurations, naming, and defaults

```yaml
name: 'my_dbt_project'
version: '1.0.0'
config-version: 2

profile: 'default'

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"
```

### 2. 📄 schema.yml (Documentation & Tests)

**Location**: Any models directory  
**Purpose**: Document models, columns, tests, and sources

```yaml
version: 2

models:
  - name: customers
    description: "Customer dimension table"
    columns:
      - name: customer_id
        description: "Primary key"
        tests:
          - unique
          - not_null
```

### 3. 📦 packages.yml (Dependencies)

**Location**: Project root directory  
**Purpose**: Define external package dependencies

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
  - package: calogica/dbt_expectations
    version: 0.10.1
```

---

## 📊 Properties Files (schema.yml / properties.yml)

### What are Properties Files?

**Properties files** (commonly named `schema.yml` or `properties.yml`) are where you define:
- 📖 Model documentation
- ✅ Tests for data quality
- 🔗 Source definitions
- 📊 Exposures and metrics
- ⚙️ Model-specific configurations

**Note**: `schema.yml` and `properties.yml` are interchangeable names for the same type of file. The community typically uses `schema.yml`, but you can use any name ending in `.yml`.

### Naming Conventions

```
models/
├── staging/
│   ├── _sources.yml          # Source definitions
│   ├── _models.yml           # Model documentation
│   ├── schema.yml            # Combined sources + models
│   └── properties.yml        # Alternative name
```

### Basic Model Documentation

```yaml
version: 2

models:
  - name: customers
    description: "One record per customer with aggregated metrics"
    
    columns:
      - name: customer_id
        description: "Primary key for customers"
        tests:
          - unique
          - not_null
      
      - name: first_name
        description: "Customer's first name"
        tests:
          - not_null
      
      - name: email
        description: "Customer's email address"
        tests:
          - unique
          - not_null
      
      - name: total_orders
        description: "Total number of orders placed"
      
      - name: lifetime_value
        description: "Total revenue from this customer"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
```

### Model Configuration in YAML

```yaml
version: 2

models:
  - name: orders
    description: "Order fact table"
    
    # Model-level configuration
    config:
      materialized: table
      schema: analytics
      tags: ['daily', 'core']
      meta:
        owner: 'data_team'
        priority: 'high'
    
    columns:
      - name: order_id
        description: "Primary key"
        tests:
          - unique
          - not_null
      
      - name: order_date
        description: "Date order was placed"
        tests:
          - not_null
      
      - name: order_status
        description: "Current status of the order"
        tests:
          - accepted_values:
              values: ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
```

### Advanced Testing in YAML

```yaml
version: 2

models:
  - name: orders
    description: "Order fact table"
    
    # Model-level tests
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - order_id
            - order_line_number
      
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1000
          max_value: 1000000
    
    columns:
      - name: order_id
        description: "Primary key"
        tests:
          - unique
          - not_null
          - relationships:
              to: ref('stg_orders')
              field: order_id
      
      - name: customer_id
        description: "Foreign key to customers"
        tests:
          - not_null
          - relationships:
              to: ref('customers')
              field: customer_id
      
      - name: order_total
        description: "Total order amount"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
      
      - name: created_at
        description: "Timestamp when order was created"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: "'2020-01-01'"
              max_value: "current_date"
```

### Documentation with Meta Fields

```yaml
version: 2

models:
  - name: fct_orders
    description: "Daily order metrics and aggregations"
    
    config:
      materialized: incremental
      unique_key: order_id
      tags: ['finance', 'daily']
    
    # Meta information for documentation
    meta:
      owner: 'analytics_team'
      slack_channel: '#data-analytics'
      contains_pii: false
      refresh_frequency: 'daily'
      depends_on:
        - 'Salesforce API'
        - 'Stripe API'
    
    columns:
      - name: order_id
        description: "Unique identifier for each order"
        meta:
          dimension_type: 'primary_key'
        tests:
          - unique
          - not_null
      
      - name: customer_email
        description: "Customer email address"
        meta:
          contains_pii: true
          masked_in: ['dev', 'staging']
```

---

## ⚙️ Project Configuration (dbt_project.yml)

### Complete dbt_project.yml Example

```yaml
# Project Information
name: 'analytics_project'
version: '1.0.0'
config-version: 2

# Profile configuration
profile: 'snowflake'

# Directory paths
model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

# Target configuration
target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

# Global configurations
vars:
  # Global variables
  start_date: '2020-01-01'
  exclude_test_data: true
  
  # dbt_utils date spine variables
  dbt_utils_dispatch_list: ['dbt_utils']

# Model configurations
models:
  analytics_project:
    
    # Staging layer - views
    staging:
      +materialized: view
      +schema: staging
      +tags: ['staging']
      
      # Source-specific configs
      salesforce:
        +tags: ['salesforce', 'crm']
      
      stripe:
        +tags: ['stripe', 'payments']
    
    # Intermediate layer
    intermediate:
      +materialized: view
      +schema: intermediate
      +tags: ['intermediate']
    
    # Marts layer
    marts:
      +materialized: table
      +schema: analytics
      +tags: ['marts']
      
      # Finance marts
      finance:
        +schema: finance
        +tags: ['finance', 'sensitive']
        +meta:
          owner: 'finance_team'
      
      # Marketing marts
      marketing:
        +schema: marketing
        +tags: ['marketing']
        
        # Large fact tables
        fct_events:
          +materialized: incremental
          +unique_key: event_id
          +on_schema_change: 'append_new_columns'

# Seed configurations
seeds:
  analytics_project:
    +schema: seeds
    +tags: ['seeds']
    
    # Specific seed configs
    country_codes:
      +column_types:
        country_code: varchar(2)
        country_name: varchar(100)

# Snapshot configurations
snapshots:
  analytics_project:
    +target_schema: snapshots
    +strategy: timestamp
    +updated_at: updated_at
    +unique_key: id
    +tags: ['snapshots']

# Test configurations
tests:
  analytics_project:
    +store_failures: true
    +schema: dbt_test_failures

# Documentation
docs:
  analytics_project:
    node_colors:
      staging: '#8BC34A'
      intermediate: '#FFC107'
      marts: '#2196F3'
```

### Model-Specific Configurations

```yaml
models:
  my_project:
    
    # All models in staging folder
    staging:
      +materialized: view
      +schema: staging
    
    # Specific model configuration
    marts:
      finance:
        # This specific model
        fct_revenue:
          +materialized: incremental
          +unique_key: transaction_id
          +incremental_strategy: merge
          +cluster_by: ['transaction_date']
          +tags: ['finance', 'revenue', 'daily']
          +grants:
            select: ['finance_team', 'executives']
```

### Variables in dbt_project.yml

```yaml
vars:
  # Global variables
  current_fiscal_year: 2024
  exclude_deleted: true
  
  # Date range variables
  lookback_days: 30
  forecast_days: 90
  
  # Feature flags
  enable_experimental_features: false
  
  # Environment-specific
  dev:
    use_sample_data: true
    max_rows: 1000
  
  prod:
    use_sample_data: false
    max_rows: null
```

**Using variables in models:**

```sql
-- models/orders.sql
select *
from {{ ref('stg_orders') }}
where created_at >= dateadd(day, -{{ var('lookback_days') }}, current_date)
{% if var('exclude_deleted') %}
  and is_deleted = false
{% endif %}
```

---

## 📦 Package Configuration (packages.yml)

### Basic packages.yml

```yaml
packages:
  # Official dbt packages
  - package: dbt-labs/dbt_utils
    version: 1.1.1
  
  - package: dbt-labs/codegen
    version: 0.12.1
  
  # Community packages
  - package: calogica/dbt_expectations
    version: 0.10.1
  
  - package: dbt-labs/audit_helper
    version: 0.9.0
```

### packages.yml with Git Repositories

```yaml
packages:
  # From dbt Hub
  - package: dbt-labs/dbt_utils
    version: 1.1.1
  
  # From Git (specific branch)
  - git: "https://github.com/dbt-labs/dbt-audit-helper.git"
    revision: main
  
  # From Git (specific tag)
  - git: "https://github.com/calogica/dbt-expectations.git"
    revision: 0.10.1
  
  # From Git (specific commit)
  - git: "https://github.com/your-org/custom-dbt-package.git"
    revision: a1b2c3d4
    warn-unpinned: false
  
  # Local package
  - local: packages/my_custom_package
```

### Modern dependencies.yml (dbt v1.6+)

```yaml
projects:
  - name: dbt_utils
    version: 1.1.1
  
  - name: dbt_expectations
    version: 0.10.1
```

---

## 🔗 Sources Configuration (sources.yml)

### What is sources.yml?

**```sources.yml```** (or **```_sources.yml```**) defines raw source tables from external systems. It's typically kept separate from model documentation files.

**Location**: Usually in `models/staging/{source_name}/` folders

**Purpose**:
- 📋 Document source tables and columns
- 🕐 Monitor data freshness
- ✅ Test source data quality
- 🔗 Create references using `{{ source() }}` function

### File Naming Conventions

```
models/
├── staging/
│   ├── salesforce/
│   │   ├── _salesforce__sources.yml      # Source definitions
│   │   ├── _salesforce__models.yml       # Model documentation
│   │   └── stg_salesforce__accounts.sql
│   ├── stripe/
│   │   ├── _sources.yml                  # Alternative: just _sources.yml
│   │   ├── _models.yml
│   │   └── stg_stripe__payments.sql
│   └── shopify/
│       ├── sources.yml                   # Alternative: sources.yml
│       └── stg_shopify__orders.sql
```

**Common patterns:**
- **```_sources.yml```** - Underscore prefix for alphabetical sorting
- **```_{source_name}__sources.yml```** - Explicit naming with source
- **```sources.yml```** - Simple naming
- Can also be combined in **```schema.yml```** with models

### Basic Source Definition

```yaml
version: 2

sources:
  - name: raw_salesforce
    description: "Raw data from Salesforce CRM"
    database: raw
    schema: salesforce
    
    tables:
      - name: accounts
        description: "Account records from Salesforce"
        
        columns:
          - name: id
            description: "Salesforce Account ID"
            tests:
              - unique
              - not_null
          
          - name: name
            description: "Account name"
      
      - name: opportunities
        description: "Sales opportunities"
        
        columns:
          - name: id
            description: "Opportunity ID"
            tests:
              - unique
              - not_null
```

### Sources with Freshness Checks

```yaml
version: 2

sources:
  - name: raw_events
    description: "Event tracking data"
    database: raw
    schema: events
    
    # Source-level freshness (applies to all tables)
    freshness:
      warn_after: {count: 12, period: hour}
      error_after: {count: 24, period: hour}
    
    # Source-level metadata
    meta:
      owner: 'data_engineering'
      contains_pii: true
    
    tables:
      - name: page_views
        description: "User page view events"
        
        # Table-level freshness (overrides source-level)
        freshness:
          warn_after: {count: 1, period: hour}
          error_after: {count: 3, period: hour}
        
        # Specify loaded_at column for freshness
        loaded_at_field: _loaded_at
        
        columns:
          - name: event_id
            description: "Unique event identifier"
            tests:
              - unique
              - not_null
          
          - name: user_id
            description: "User who triggered event"
            tests:
              - not_null
          
          - name: event_timestamp
            description: "When event occurred"
            tests:
              - not_null
      
      - name: button_clicks
        description: "Button click events"
        
        freshness:
          warn_after: {count: 2, period: hour}
          error_after: {count: 6, period: hour}
        
        loaded_at_field: _loaded_at
```

### Sources with Quoting

```yaml
version: 2

sources:
  - name: postgres_backend
    database: production
    schema: public
    
    # Enable quoting for this source
    quoting:
      database: true
      schema: true
      identifier: true
    
    tables:
      - name: Users
        # Lowercase identifier with quoting
        identifier: users
        
        columns:
          - name: id
          - name: email
```

### External Sources

```yaml
version: 2

sources:
  - name: s3_data
    description: "Data stored in S3"
    
    tables:
      - name: customer_events
        description: "Customer event logs"
        
        # External table configuration (Snowflake example)
        external:
          location: "@s3_stage/customer_events/"
          file_format: "(type = parquet)"
          auto_refresh: true
          pattern: ".*[.]parquet"
        
        columns:
          - name: event_id
          - name: customer_id
          - name: event_type
```

---

## 🎯 Advanced YAML Configurations

### Exposures

```yaml
version: 2

exposures:
  - name: weekly_revenue_dashboard
    description: "Executive dashboard showing weekly revenue metrics"
    type: dashboard
    maturity: high
    
    url: https://looker.company.com/dashboards/123
    
    owner:
      name: Analytics Team
      email: analytics@company.com
    
    depends_on:
      - ref('fct_orders')
      - ref('dim_customers')
      - ref('dim_products')
    
    tags: ['finance', 'executive']
    
    meta:
      refresh_frequency: 'daily'
      stakeholders:
        - 'CFO'
        - 'VP of Sales'

  - name: customer_segmentation_ml
    description: "ML model for customer segmentation"
    type: ml
    maturity: medium
    
    owner:
      name: Data Science Team
      email: datascience@company.com
    
    depends_on:
      - ref('fct_customer_features')
    
    tags: ['ml', 'customer']
```

### Metrics (dbt v1.6+)

```yaml
version: 2

metrics:
  - name: total_revenue
    label: Total Revenue
    description: "Sum of all order revenue"
    
    type: sum
    sql: order_total
    timestamp: order_date
    time_grains: [day, week, month, quarter, year]
    
    dimensions:
      - customer_segment
      - product_category
    
    filters:
      - field: order_status
        operator: '='
        value: "'completed'"
    
    meta:
      team: finance

  - name: average_order_value
    label: Average Order Value
    description: "Average revenue per order"
    
    type: average
    sql: order_total
    timestamp: order_date
    time_grains: [day, week, month]
    
    dimensions:
      - customer_segment
    
    meta:
      team: analytics
```

### Semantic Models (dbt v1.6+)

```yaml
version: 2

semantic_models:
  - name: orders
    description: "Order transactions"
    model: ref('fct_orders')
    
    entities:
      - name: order_id
        type: primary
      - name: customer_id
        type: foreign
    
    dimensions:
      - name: order_date
        type: time
        type_params:
          time_granularity: day
      
      - name: order_status
        type: categorical
    
    measures:
      - name: order_total
        agg: sum
      
      - name: order_count
        agg: count
        expr: order_id
```

### Access Control

```yaml
version: 2

models:
  - name: sensitive_customer_data
    description: "Customer data with PII"
    
    config:
      materialized: table
      schema: restricted
      
      # Snowflake grants
      grants:
        select: ['analytics_team', 'data_science_team']
      
      # BigQuery access
      labels:
        sensitivity: 'high'
        department: 'finance'
    
    columns:
      - name: customer_id
      - name: email
        meta:
          pii: true
      - name: ssn
        meta:
          pii: true
          masked: true
```

### Custom Schema and Alias

```yaml
version: 2

models:
  - name: customers
    description: "Customer dimension"
    
    config:
      # Custom schema (will be prefixed based on target)
      schema: dimensions
      
      # Custom table name in database
      alias: dim_customers
      
      # Full control over schema
      # schema: "{{ 'prod_analytics' if target.name == 'prod' else 'dev_analytics' }}"
```

### External Sources

```yaml
version: 2

sources:
  - name: s3_data
    description: "Data stored in S3"
    
    tables:
      - name: customer_events
        description: "Customer event logs"
        
        # External table configuration (Snowflake example)
        external:
          location: "@s3_stage/customer_events/"
          file_format: "(type = parquet)"
          auto_refresh: true
          pattern: ".*[.]parquet"
        
        columns:
          - name: event_id
          - name: customer_id
          - name: event_type
```

### Multi-Source Configuration

**When you have multiple sources, organize by system:**

```
models/
├── staging/
│   ├── salesforce/
│   │   ├── _salesforce__sources.yml
│   │   ├── stg_salesforce__accounts.sql
│   │   └── stg_salesforce__opportunities.sql
│   ├── stripe/
│   │   ├── _stripe__sources.yml
│   │   └── stg_stripe__payments.sql
│   ├── google_analytics/
│   │   ├── _ga__sources.yml
│   │   └── stg_ga__sessions.sql
│   └── internal_db/
│       ├── _internal__sources.yml
│       └── stg_internal__users.sql
```

### Combined Sources File

**Alternative: One sources file for all staging sources**

```
models/
├── staging/
│   ├── _sources.yml                    # All sources defined here
│   ├── salesforce/
│   │   ├── _salesforce__models.yml
│   │   └── stg_salesforce__accounts.sql
│   ├── stripe/
│   │   ├── _stripe__models.yml
│   │   └── stg_stripe__payments.sql
│   └── shopify/
│       ├── _shopify__models.yml
│       └── stg_shopify__orders.sql
```

**models/staging/_sources.yml:**

```yaml
version: 2

sources:
  # Salesforce sources
  - name: salesforce
    database: raw
    schema: salesforce_production
    
    tables:
      - name: accounts
        # ... config
      
      - name: opportunities
        # ... config
  
  # Stripe sources
  - name: stripe
    database: raw
    schema: stripe_production
    
    tables:
      - name: payments
        # ... config
      
      - name: customers
        # ... config
  
  # Shopify sources
  - name: shopify
    database: raw
    schema: shopify_production
    
    tables:
      - name: orders
        # ... config
```

### Source Testing Best Practices

```yaml
version: 2

sources:
  - name: production_db
    description: "Production application database"
    
    tables:
      - name: users
        description: "User accounts"
        
        # Test source data quality
        columns:
          - name: id
            description: "Primary key"
            tests:
              - unique
              - not_null
          
          - name: email
            description: "User email"
            tests:
              - unique
              - not_null
              - dbt_utils.email_format
          
          - name: created_at
            description: "Account creation timestamp"
            tests:
              - not_null
              - dbt_expectations.expect_column_values_to_be_between:
                  min_value: "'2020-01-01'"
                  max_value: "current_timestamp"
          
          - name: status
            description: "Account status"
            tests:
              - accepted_values:
                  values: ['active', 'inactive', 'suspended', 'deleted']
```

### Using Sources in Models

**After defining sources, reference them in staging models:**

```sql
-- models/staging/salesforce/stg_salesforce__accounts.sql

with source as (
    
    select * from {{ source('salesforce', 'accounts') }}

),

renamed as (

    select
        id as account_id,
        name as account_name,
        industry,
        annual_revenue,
        created_date,
        _fivetran_synced as loaded_at
    
    from source

)

select * from renamed
```

### Source Freshness Commands

```bash
# Check all source freshness
dbt source freshness

# Check specific source
dbt source freshness --select source:salesforce

# Output to JSON for CI/CD
dbt source freshness --output target/freshness.json

# Check freshness for specific tables
dbt source freshness --select source:salesforce.accounts
```

### Source Freshness in CI/CD

**Example CI configuration:**

```yaml
# .github/workflows/dbt_ci.yml

- name: Check Source Freshness
  run: |
    dbt source freshness --output target/freshness.json
    
- name: Upload Freshness Results
  if: always()
  uses: actions/upload-artifact@v2
  with:
    name: freshness-results
    path: target/freshness.json
```

### Source Documentation

```yaml
version: 2

sources:
  - name: salesforce
    description: |
      ## Salesforce CRM Data
      
      Raw data synced from Salesforce using Fivetran.
      
      **Sync Frequency:** Every 15 minutes
      **Owner:** Sales Operations Team
      **Documentation:** https://help.salesforce.com/
    
    meta:
      owner: 'sales_ops@company.com'
      contains_pii: true
      sync_tool: 'fivetran'
      sync_frequency: '15 minutes'
    
    tables:
      - name: accounts
        description: |
          **Business Definition:**
          Companies and organizations tracked in Salesforce.
          
          **Key Fields:**
          - `id`: Unique account identifier
          - `name`: Company name
          - `owner_id`: Sales rep responsible for account
          
          **Update Pattern:**
          Incremental updates based on `SystemModstamp`
        
        identifier: Account  # Actual table name if different
        
        meta:
          business_owner: 'VP of Sales'
          data_steward: 'sales_ops@company.com'
```

---

## 🎯 Selectors Configuration (selectors.yml)

### What is selectors.yml?

**```selectors.yml```** allows you to define reusable selection logic for running specific groups of models.

**Location**: Project root directory

### Basic Selectors

```yaml
selectors:
  - name: daily_models
    description: "Models that run daily"
    definition:
      tag: daily
  
  - name: hourly_models
    description: "Models that run hourly"
    definition:
      tag: hourly
  
  - name: staging_only
    description: "All staging models"
    definition:
      path: models/staging/
```

**Using selectors:**

```bash
# Run daily models
dbt run --selector daily_models

# Test hourly models
dbt test --selector hourly_models

# Build staging only
dbt build --selector staging_only
```

### Advanced Selectors

```yaml
selectors:
  - name: nightly_run
    description: "All models for nightly production run"
    definition:
      union:
        - tag: nightly
        - intersection:
            - tag: core
            - config.materialized: table
  
  - name: ci_slim
    description: "Modified models and dependencies for CI"
    definition:
      union:
        - method: state
          state: modified
          children: true
        - method: state
          state: new
  
  - name: finance_critical
    description: "Critical finance models"
    definition:
      intersection:
        - tag: finance
        - tag: critical
        - config.materialized: table
  
  - name: exclude_tests
    description: "All models except test/experimental"
    definition:
      exclude:
        - tag: test
        - tag: experimental
        - path: models/scratch/
```

### Complex Selection Logic

```yaml
selectors:
  - name: production_marts
    description: "Production-ready mart models"
    definition:
      intersection:
        # Include marts
        - path: models/marts/
        
        # Exclude experimental
        - exclude:
            - tag: experimental
        
        # Only tables and incremental
        - union:
            - config.materialized: table
            - config.materialized: incremental
  
  - name: sla_models
    description: "Models with SLA requirements"
    definition:
      union:
        - tag: sla_1hour
        - tag: sla_4hour
        - tag: sla_24hour
  
  - name: modified_with_tests
    description: "Modified models with their tests"
    definition:
      union:
        # Modified models
        - method: state
          state: modified
          children: true
        
        # Tests for those models
        - method: state
          state: modified
          indirect_selection: eager
```

### Default Selector

```yaml
selectors:
  - name: default
    description: "Default selection for dbt run"
    definition:
      union:
        - tag: daily
        - config.materialized: incremental
    
    # Set as default
    default: true
```

**With default selector, these are equivalent:**

```bash
dbt run
dbt run --selector default
```

---

## 🎯 Best Practices

### 1. 🔒 Profile Security

**Never commit profiles.yml to version control:**

```bash
# .gitignore
profiles.yml
.env
*.env
```

**Always use environment variables:**

```yaml
# ✅ CORRECT - Secure
outputs:
  prod:
    type: snowflake
    password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
    user: "{{ env_var('SNOWFLAKE_USER') }}"

# ❌ WRONG - Insecure
outputs:
  prod:
    type: snowflake
    password: mysecretpassword
    user: prod_user
```

**Use .env files for local development:**

```bash
# .env
SNOWFLAKE_ACCOUNT=abc123
SNOWFLAKE_USER=my_user
SNOWFLAKE_PASSWORD=my_password
SNOWFLAKE_ROLE=transformer
SNOWFLAKE_WAREHOUSE=transforming
```

**Load .env with tools like direnv or python-dotenv**

### 2. 📁 File Organization

**Recommended Structure:**

```
models/
├── staging/
│   ├── salesforce/
│   │   ├── _salesforce__models.yml
│   │   ├── _salesforce__sources.yml
│   │   ├── stg_salesforce__accounts.sql
│   │   └── stg_salesforce__opportunities.sql
│   └── stripe/
│       ├── _stripe__models.yml
│       ├── _stripe__sources.yml
│       └── stg_stripe__payments.sql
├── intermediate/
│   └── finance/
│       ├── _int_finance__models.yml
│       └── int_customer_payments.sql
└── marts/
    ├── finance/
    │   ├── _finance__models.yml
    │   ├── fct_orders.sql
    │   └── dim_customers.sql
    └── marketing/
        ├── _marketing__models.yml
        └── fct_campaigns.sql
```

**Naming Conventions:**
- **```__{source}__sources.yml```** - Source definitions
- **```__{domain}__models.yml```** - Model documentation
- One YAML file per folder or domain
- Prefix with underscore for easy identification

### 3. 📝 Documentation Standards

```yaml
version: 2

models:
  - name: fct_orders
    description: |
      **Business Definition:**
      Order fact table containing one row per order with associated metrics.
      
      **Grain:**
      One row per order_id
      
      **Updates:**
      Updated incrementally every hour
      
      **Key Transformations:**
      - Combines order header and line items
      - Calculates order totals and discounts
      - Enriches with customer segment information
      
      **Known Issues:**
      - Orders placed before 2020-01-01 may have incomplete data
      - Cancelled orders remain in the table with status = 'cancelled'
    
    config:
      materialized: incremental
      unique_key: order_id
    
    meta:
      owner: 'analytics_team'
      slack_channel: '#data-analytics'
      jira_epic: 'DATA-123'
    
    columns:
      - name: order_id
        description: |
          Primary key - Unique identifier for each order.
          Format: ORD-XXXXXXXX
        tests:
          - unique
          - not_null
        meta:
          dimension_type: 'primary_key'
```

### 4. ✅ Testing Strategy

```yaml
version: 2

models:
  - name: fct_orders
    description: "Order fact table"
    
    # Model-level tests
    tests:
      # Test unique combination
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - order_id
            - order_line_number
      
      # Test row count
      - dbt_utils.expression_is_true:
          expression: "count(*) > 1000"
      
      # Test recency
      - dbt_utils.recency:
          datepart: day
          field: order_date
          interval: 1
    
    columns:
      - name: order_id
        description: "Primary key"
        tests:
          # Standard tests
          - unique
          - not_null
          
          # Relationship test
          - relationships:
              to: ref('stg_orders')
              field: order_id
      
      - name: order_total
        description: "Total order amount"
        tests:
          # Range test
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1000000
          
          # Not null
          - not_null
      
      - name: order_status
        description: "Order status"
        tests:
          # Accepted values
          - accepted_values:
              values: ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
              quote: false
```

### 4. ✅ Testing Strategy

```yaml
version: 2

models:
  - name: fct_orders
    description: "Order fact table"
    
    # Model-level tests
    tests:
      # Test unique combination
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - order_id
            - order_line_number
      
      # Test row count
      - dbt_utils.expression_is_true:
          expression: "count(*) > 1000"
      
      # Test recency
      - dbt_utils.recency:
          datepart: day
          field: order_date
          interval: 1
    
    columns:
      - name: order_id
        description: "Primary key"
        tests:
          # Standard tests
          - unique
          - not_null
          
          # Relationship test
          - relationships:
              to: ref('stg_orders')
              field: order_id
      
      - name: order_total
        description: "Total order amount"
        tests:
          # Range test
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1000000
          
          # Not null
          - not_null
      
      - name: order_status
        description: "Order status"
        tests:
          # Accepted values
          - accepted_values:
              values: ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
              quote: false
```

### 5. 🏗️ Configuration Hierarchy

**Best Practice Configuration Strategy:**

```yaml
# dbt_project.yml - Broad defaults
models:
  my_project:
    staging:
      +materialized: view
      +schema: staging
    
    marts:
      +materialized: table
      +schema: analytics

# models/marts/finance/_finance__models.yml - Domain-specific
models:
  - name: fct_orders
    config:
      materialized: incremental
      unique_key: order_id
      tags: ['finance', 'daily']

# models/marts/finance/fct_orders.sql - Model-specific overrides
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
```

**Configuration Precedence (Highest to Lowest):**
1. In-model config block
2. schema.yml model config
3. dbt_project.yml specific folder
4. dbt_project.yml parent folder
5. dbt_project.yml project level
6. dbt defaults

### 5. 🏗️ Configuration Hierarchy

**Best Practice Configuration Strategy:**

```yaml
# dbt_project.yml - Broad defaults
models:
  my_project:
    staging:
      +materialized: view
      +schema: staging
    
    marts:
      +materialized: table
      +schema: analytics

# models/marts/finance/_finance__models.yml - Domain-specific
models:
  - name: fct_orders
    config:
      materialized: incremental
      unique_key: order_id
      tags: ['finance', 'daily']

# models/marts/finance/fct_orders.sql - Model-specific overrides
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
```

**Configuration Precedence (Highest to Lowest):**
1. In-model config block
2. schema.yml model config
3. dbt_project.yml specific folder
4. dbt_project.yml parent folder
5. dbt_project.yml project level
6. dbt defaults

### 6. 🔄 Source Freshness Best Practices

```yaml
version: 2

sources:
  - name: production_db
    description: "Production database"
    
    # Default freshness for all tables
    freshness:
      warn_after: {count: 12, period: hour}
      error_after: {count: 24, period: hour}
    
    tables:
      # Critical tables - strict freshness
      - name: orders
        freshness:
          warn_after: {count: 1, period: hour}
          error_after: {count: 2, period: hour}
        loaded_at_field: created_at
      
      # Less critical - relaxed freshness
      - name: products
        freshness:
          warn_after: {count: 24, period: hour}
          error_after: {count: 48, period: hour}
        loaded_at_field: updated_at
      
      # Reference data - very relaxed
      - name: countries
        freshness:
          warn_after: {count: 7, period: day}
          error_after: {count: 30, period: day}
        loaded_at_field: last_modified
```

---

## 📝 Complete Examples

### Example 1: E-commerce Project Structure

**dbt_project.yml:**
```yaml
name: 'ecommerce_analytics'
version: '1.0.0'
config-version: 2

profile: 'snowflake'

model-paths: ["models"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets: ["target", "dbt_packages"]

vars:
  exclude_deleted_customers: true
  fiscal_year_start_month: 1

models:
  ecommerce_analytics:
    staging:
      +materialized: view
      +schema: staging
      +tags: ['staging']
    
    intermediate:
      +materialized: view
      +schema: intermediate
      +tags: ['intermediate']
    
    marts:
      +materialized: table
      +schema: analytics
      +tags: ['marts']
      
      core:
        +tags: ['core']
      
      finance:
        +schema: finance
        +tags: ['finance', 'sensitive']
        +grants:
          select: ['finance_team']
      
      marketing:
        +schema: marketing
        +tags: ['marketing']

seeds:
  ecommerce_analytics:
    +schema: seeds

snapshots:
  ecommerce_analytics:
    +target_schema: snapshots
    +unique_key: id
    +strategy: timestamp
    +updated_at: updated_at
```

**models/staging/shopify/_shopify__sources.yml:**
```yaml
version: 2

sources:
  - name: shopify
    description: "Raw data from Shopify e-commerce platform"
    database: raw
    schema: shopify
    
    freshness:
      warn_after: {count: 6, period: hour}
      error_after: {count: 12, period: hour}
    
    meta:
      owner: 'data_engineering'
      contains_pii: true
    
    tables:
      - name: orders
        description: "Order transactions"
        loaded_at_field: _synced_at
        
        freshness:
          warn_after: {count: 1, period: hour}
          error_after: {count: 3, period: hour}
        
        columns:
          - name: id
            description: "Order ID"
            tests:
              - unique
              - not_null
          
          - name: customer_id
            description: "Customer who placed the order"
            tests:
              - not_null
              - relationships:
                  to: source('shopify', 'customers')
                  field: id
          
          - name: total_price
            description: "Total order price"
            tests:
              - not_null
              - dbt_utils.accepted_range:
                  min_value: 0
          
          - name: created_at
            description: "Order creation timestamp"
            tests:
              - not_null
      
      - name: customers
        description: "Customer records"
        loaded_at_field: _synced_at
        
        columns:
          - name: id
            description: "Customer ID"
            tests:
              - unique
              - not_null
          
          - name: email
            description: "Customer email"
            tests:
              - unique
              - not_null
          
          - name: created_at
            tests:
              - not_null
      
      - name: products
        description: "Product catalog"
        loaded_at_field: _synced_at
        
        freshness:
          warn_after: {count: 24, period: hour}
        
        columns:
          - name: id
            tests:
              - unique
              - not_null
```

**models/staging/shopify/_shopify__models.yml:**
```yaml
version: 2

models:
  - name: stg_shopify__orders
    description: "Staged order data with basic cleaning"
    
    columns:
      - name: order_id
        description: "Primary key"
        tests:
          - unique
          - not_null
      
      - name: customer_id
        description: "Foreign key to customers"
        tests:
          - not_null
          - relationships:
              to: ref('stg_shopify__customers')
              field: customer_id
      
      - name: order_total
        description: "Total order amount in USD"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
      
      - name: order_status
        tests:
          - accepted_values:
              values: ['pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded']
      
      - name: created_at
        tests:
          - not_null

  - name: stg_shopify__customers
    description: "Staged customer data"
    
    columns:
      - name: customer_id
        description: "Primary key"
        tests:
          - unique
          - not_null
      
      - name: email
        description: "Customer email"
        tests:
          - unique
          - not_null
      
      - name: first_order_date
        description: "Date of first order"
```

**models/marts/core/_core__models.yml:**
```yaml
version: 2

models:
  - name: fct_orders
    description: |
      **Order Fact Table**
      
      One row per order with associated metrics and dimensions.
      Updated incrementally every hour.
      
      **Grain:** One row per order_id
    
    config:
      materialized: incremental
      unique_key: order_id
      on_schema_change: append_new_columns
      tags: ['core', 'hourly']
    
    meta:
      owner: 'analytics_team'
      slack_channel: '#data-core'
      priority: 'high'
    
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
      
      - dbt_utils.recency:
          datepart: day
          field: order_date
          interval: 1
    
    columns:
      - name: order_id
        description: "Primary key - unique order identifier"
        tests:
          - unique
          - not_null
        meta:
          dimension_type: 'primary_key'
      
      - name: customer_id
        description: "Foreign key to dim_customers"
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id
      
      - name: order_date
        description: "Date order was placed"
        tests:
          - not_null
      
      - name: order_total
        description: "Total order amount in USD"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100000
      
      - name: order_status
        description: "Current order status"
        tests:
          - accepted_values:
              values: ['pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded']
      
      - name: is_first_order
        description: "Boolean flag for customer's first order"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: dim_customers
    description: |
      **Customer Dimension Table**
      
      One row per customer with lifetime metrics.
      Full refresh daily.
      
      **Grain:** One row per customer_id
    
    config:
      materialized: table
      tags: ['core', 'daily']
    
    meta:
      owner: 'analytics_team'
      contains_pii: true
    
    columns:
      - name: customer_id
        description: "Primary key"
        tests:
          - unique
          - not_null
      
      - name: email
        description: "Customer email address"
        tests:
          - unique
        meta:
          pii: true
      
      - name: first_order_date
        description: "Date of first order"
      
      - name: total_orders
        description: "Lifetime order count"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
      
      - name: lifetime_value
        description: "Total lifetime revenue"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
      
      - name: customer_segment
        description: "Customer segment classification"
        tests:
          - accepted_values:
              values: ['new', 'active', 'at_risk', 'churned', 'vip']
```

### Example 2: SaaS Metrics Project

**models/marts/product/_product__models.yml:**
```yaml
version: 2

models:
  - name: fct_daily_active_users
    description: "Daily active user metrics"
    
    config:
      materialized: incremental
      unique_key: date_day
      incremental_strategy: delete+insert
      tags: ['product', 'daily']
    
    columns:
      - name: date_day
        description: "Date of activity"
        tests:
          - unique
          - not_null
      
      - name: daily_active_users
        description: "Count of distinct active users"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
      
      - name: new_users
        description: "Count of new user signups"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0

exposures:
  - name: product_dashboard
    description: "Daily product metrics dashboard"
    type: dashboard
    maturity: high
    
    url: https://looker.company.com/dashboards/product
    
    owner:
      name: Product Team
      email: product@company.com
    
    depends_on:
      - ref('fct_daily_active_users')
      - ref('fct_feature_usage')
    
    tags: ['product']
```

---

## 🚀 YAML Validation & Tips

### Common YAML Mistakes to Avoid

```yaml
# ❌ WRONG - Missing version
models:
  - name: customers

# ✅ CORRECT
version: 2
models:
  - name: customers

# ❌ WRONG - Incorrect indentation
version: 2
models:
- name: customers
  columns:
  - name: customer_id

# ✅ CORRECT - Consistent 2-space indentation
version: 2
models:
  - name: customers
    columns:
      - name: customer_id

# ❌ WRONG - Missing quotes on special characters
tests:
  - accepted_values:
      values: [pending, order:confirmed]

# ✅ CORRECT - Quote values with special characters
tests:
  - accepted_values:
      values: ['pending', 'order:confirmed']

# ❌ WRONG - Using tabs instead of spaces
models:
	- name: customers  # Tab used here

# ✅ CORRECT - Use spaces only
models:
  - name: customers  # Spaces used
```

### YAML Linting

**Install and use yamllint:**

```bash
# Install yamllint
pip install yamllint

# Lint all YAML files
yamllint models/

# Lint specific file
yamllint dbt_project.yml
```

**Create `.yamllint` config:**

```yaml
extends: default

rules:
  line-length:
    max: 120
  indentation:
    spaces: 2
  comments:
    min-spaces-from-content: 1
```

---

## 🎓 Quick Reference

### All dbt YAML Files

| File | Purpose | Key Sections | Location |
|------|---------|--------------|----------|
| **```profiles.yml```** | Database connections | `outputs`, authentication, threads | `~/.dbt/` |
| **```dbt_project.yml```** | Project config | `models`, `seeds`, `vars`, paths | Root |
| **```schema.yml```** | Documentation & tests | `models`, `sources`, `columns`, `tests` | models/ folders |
| **```properties.yml```** | Same as schema.yml | `models`, `sources`, `columns`, `tests` | models/ folders |
| **```sources.yml```** | Source definitions | `sources`, `tables`, `freshness` | staging/ folders |
| **```packages.yml```** | Dependencies | `packages` list | Root |
| **```dependencies.yml```** | Modern dependencies | `projects` list | Root |
| **```selectors.yml```** | Selection logic | `selectors`, `definition` | Root |

### File Organization Patterns

| Pattern | When to Use | Example |
|---------|-------------|---------|
| **```_sources.yml```** | Separate sources from models | `staging/salesforce/_sources.yml` |
| **```_{name}__sources.yml```** | Explicit source naming | `staging/salesforce/_salesforce__sources.yml` |
| **```_{name}__models.yml```** | Model documentation | `staging/salesforce/_salesforce__models.yml` |
| **```schema.yml```** | Combined sources + models | `staging/salesforce/schema.yml` |
| **```properties.yml```** | Alternative to schema.yml | `marts/finance/properties.yml` |

### Essential YAML Syntax

| Element | Syntax | Example |
|---------|--------|---------|
| **String** | `key: value` | `name: customers` |
| **Number** | `key: 123` | `count: 100` |
| **Boolean** | `key: true/false` | `enabled: true` |
| **List** | `- item` | `- unique`<br/>`- not_null` |
| **Dictionary** | `key:`<br/>&nbsp;&nbsp;`subkey: value` | `config:`<br/>&nbsp;&nbsp;`materialized: table` |
| **Multi-line** | `key: \|` or `key: >` | `description: \|`<br/>&nbsp;&nbsp;`Multi-line text` |
| **Inline list** | `key: [item1, item2]` | `values: ['a', 'b']` |
| **Comments** | `# comment` | `# This is a comment` |

### Common Test Configurations

```yaml
# Standard tests
tests:
  - unique
  - not_null
  - accepted_values:
      values: ['a', 'b', 'c']
  - relationships:
      to: ref('other_table')
      field: id

# dbt_utils tests
tests:
  - dbt_utils.accepted_range:
      min_value: 0
      max_value: 100
  - dbt_utils.unique_combination_of_columns:
      combination_of_columns:
        - column1
        - column2
  - dbt_utils.expression_is_true:
      expression: "column_a > column_b"

# dbt_expectations tests
tests:
  - dbt_expectations.expect_column_values_to_be_between:
      min_value: 0
      max_value: 100
  - dbt_expectations.expect_column_values_to_match_regex:
      regex: "^[A-Z]{3}$"
```

---

<div align="center">

### 🎯 Key Takeaways

![Takeaway 1](https://img.shields.io/badge/💡_Version-Always_include_version:_2-4CAF50?style=for-the-badge)
![Takeaway 2](https://img.shields.io/badge/💡_Organization-One_YAML_per_folder-2196F3?style=for-the-badge)
![Takeaway 3](https://img.shields.io/badge/💡_Documentation-Describe_everything-9C27B0?style=for-the-badge)

</div>

---

*Note: YAML syntax is sensitive to indentation and spacing. Always use 2 spaces for indentation, never tabs. Refer to [dbt documentation](https://docs.getdbt.com) for the latest YAML specifications.*
