# 🚀 dbt + Airflow + Cosmos Orchestration Guide

<div align="center">

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Airflow](https://img.shields.io/badge/Airflow-017CEE?style=for-the-badge&logo=apacheairflow&logoColor=white)
![Cosmos](https://img.shields.io/badge/Cosmos-00C7B7?style=for-the-badge)

</div>

A comprehensive guide to orchestrating dbt pipelines with Apache Airflow using Astronomer Cosmos - automatically converting dbt models into Airflow DAGs.

---

## 📑 Table of Contents

1. [🔍 What is Astronomer Cosmos?](#-what-is-astronomer-cosmos)
2. [🎯 Why Use Cosmos?](#-why-use-cosmos)
3. [⚙️ Installation & Setup](#️-installation--setup)
4. [📝 Basic DAG Creation](#-basic-dag-creation)
5. [🛠️ Configuration Options](#️-configuration-options)
6. [🔧 Advanced Patterns](#-advanced-patterns)
7. [📊 Execution Modes](#-execution-modes)
8. [💡 Best Practices](#-best-practices)
9. [📈 Real-World Examples](#-real-world-examples)
10. [🔍 Troubleshooting](#-troubleshooting)

---

## 🔍 What is Astronomer Cosmos?

**Astronomer Cosmos** is an open-source library that automatically converts your dbt project into Airflow DAGs, preserving the dependency structure and allowing native Airflow orchestration.

### Key Features

✅ **Automatic DAG Generation** - Converts dbt models to Airflow tasks  
✅ **Dependency Preservation** - Maintains dbt's `ref()` and `source()` relationships  
✅ **Native Airflow Integration** - Use Airflow features (retries, alerts, sensors)  
✅ **Multiple Execution Modes** - Local, Docker, Kubernetes, dbt Cloud  
✅ **Selective Execution** - Run specific models, tags, or paths  
✅ **Testing Support** - Automatically includes dbt tests  
✅ **Dynamic Task Mapping** - Scales with your dbt project

---

## 🎯 Why Use Cosmos?

### Traditional dbt + Airflow Challenges

❌ **Manual DAG Creation** - Write Airflow tasks for each dbt model  
❌ **Dependency Management** - Manually define task dependencies  
❌ **Maintenance Overhead** - Keep DAGs in sync with dbt changes  
❌ **Limited Visibility** - dbt runs as single monolithic task

### Cosmos Benefits

✅ **Zero/Low Code** - Auto-generates DAGs from dbt project  
✅ **Automatic Dependencies** - Respects dbt lineage  
✅ **Fine-Grained Control** - Each model is an Airflow task  
✅ **Better Observability** - See individual model status  
✅ **Parallel Execution** - Airflow handles parallelism  
✅ **Easy Testing** - Run/test specific models on failures

---

## ⚙️ Installation & Setup

### 1. Install Cosmos

```bash
# Install from PyPI
pip install astronomer-cosmos

# Or with specific execution mode
pip install "astronomer-cosmos[dbt-snowflake]"
pip install "astronomer-cosmos[dbt-bigquery]"
pip install "astronomer-cosmos[dbt-redshift]"
pip install "astronomer-cosmos[dbt-postgres]"

# Install with Docker support
pip install "astronomer-cosmos[docker]"

# Install with Kubernetes support
pip install "astronomer-cosmos[kubernetes]"
```

### 2. Project Structure

```
my-airflow-project/
├── dags/
│   ├── dbt_dag.py                    # Your Cosmos DAG
│   └── other_dags.py
├── dbt/
│   └── my_dbt_project/              # Your dbt project
│       ├── dbt_project.yml
│       ├── models/
│       ├── macros/
│       ├── tests/
│       ├── seeds/
│       └── snapshots/
├── plugins/
├── include/
└── requirements.txt
```

### 3. Configure Airflow Connection

```python
# Using Airflow UI: Admin -> Connections
# Or via environment variables

# Snowflake Example
export AIRFLOW_CONN_SNOWFLAKE_DEFAULT='{"conn_type": "snowflake", 
    "login": "username", 
    "password": "password", 
    "schema": "analytics", 
    "extra": {
        "account": "xy12345.us-east-1",
        "warehouse": "transforming",
        "database": "analytics_db",
        "role": "transformer"
    }}'

# BigQuery Example
export AIRFLOW_CONN_BIGQUERY_DEFAULT='{"conn_type": "google_cloud_platform",
    "extra": {
        "project": "my-gcp-project",
        "keyfile_path": "/path/to/keyfile.json"
    }}'

# Postgres Example
export AIRFLOW_CONN_POSTGRES_DEFAULT='postgresql://user:password@host:5432/database'
```

---

## 📝 Basic DAG Creation

### Example 1: Minimal Cosmos DAG

```python
# dags/dbt_basic_dag.py

from datetime import datetime
from pathlib import Path

from airflow import DAG
from cosmos import DbtDag, ProjectConfig, ProfileConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping

# Define dbt project location
dbt_project_path = Path("/usr/local/airflow/dbt/my_dbt_project")

# Create profile configuration
profile_config = ProfileConfig(
    profile_name="default",
    target_name="prod",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_default",
        profile_args={
            "database": "analytics_db",
            "schema": "analytics"
        }
    )
)

# Create Cosmos DAG
my_dbt_dag = DbtDag(
    # Airflow DAG parameters
    dag_id="dbt_basic_pipeline",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
    
    # Cosmos parameters
    project_config=ProjectConfig(
        dbt_project_path=dbt_project_path,
    ),
    profile_config=profile_config,
    
    # Operator configuration
    operator_args={
        "install_deps": True,  # Run dbt deps before execution
    },
)
```

---

### Example 2: DAG with Custom Configuration

```python
# dags/dbt_advanced_dag.py

from datetime import datetime, timedelta
from pathlib import Path

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping

# DAG default arguments
default_args = {
    "owner": "data-team",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "email": ["data-team@company.com"],
    "email_on_failure": True,
}

with DAG(
    dag_id="dbt_advanced_pipeline",
    start_date=datetime(2024, 1, 1),
    schedule_interval="0 2 * * *",  # 2 AM daily
    catchup=False,
    default_args=default_args,
    tags=["dbt", "analytics", "daily"],
) as dag:
    
    # Pre-dbt task
    start = EmptyOperator(task_id="start")
    
    # dbt TaskGroup (not a full DAG)
    dbt_tg = DbtTaskGroup(
        group_id="dbt_transformation",
        
        # Project configuration
        project_config=ProjectConfig(
            dbt_project_path="/usr/local/airflow/dbt/my_dbt_project",
            models_relative_path="models",
            seeds_relative_path="seeds",
            snapshots_relative_path="snapshots",
        ),
        
        # Profile configuration
        profile_config=ProfileConfig(
            profile_name="default",
            target_name="prod",
            profile_mapping=SnowflakeUserPasswordProfileMapping(
                conn_id="snowflake_default",
                profile_args={
                    "database": "analytics_db",
                    "schema": "analytics",
                    "warehouse": "transforming_xl",
                }
            ),
        ),
        
        # Execution configuration
        execution_config=ExecutionConfig(
            dbt_executable_path="/usr/local/bin/dbt",
        ),
        
        # Operator arguments
        operator_args={
            "install_deps": True,
            "full_refresh": False,
        },
        
        # dbt arguments
        dbt_args={
            "vars": {
                "start_date": "{{ ds }}",
                "end_date": "{{ macros.ds_add(ds, 1) }}",
            },
        },
    )
    
    # Post-dbt task
    end = EmptyOperator(task_id="end")
    
    # Define dependencies
    start >> dbt_tg >> end
```

---

### Example 3: Multiple dbt Projects in One DAG

```python
# dags/multi_project_dag.py

from datetime import datetime
from pathlib import Path

from airflow import DAG
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping

with DAG(
    dag_id="multi_dbt_project_pipeline",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:
    
    # First dbt project - Staging
    staging_tg = DbtTaskGroup(
        group_id="staging_models",
        project_config=ProjectConfig(
            dbt_project_path="/usr/local/airflow/dbt/staging_project",
        ),
        profile_config=ProfileConfig(
            profile_name="default",
            target_name="prod",
            profile_mapping=SnowflakeUserPasswordProfileMapping(
                conn_id="snowflake_default",
                profile_args={"schema": "staging"}
            ),
        ),
    )
    
    # Second dbt project - Analytics
    analytics_tg = DbtTaskGroup(
        group_id="analytics_models",
        project_config=ProjectConfig(
            dbt_project_path="/usr/local/airflow/dbt/analytics_project",
        ),
        profile_config=ProfileConfig(
            profile_name="default",
            target_name="prod",
            profile_mapping=SnowflakeUserPasswordProfileMapping(
                conn_id="snowflake_default",
                profile_args={"schema": "analytics"}
            ),
        ),
    )
    
    # Dependencies
    staging_tg >> analytics_tg
```

---

## 🛠️ Configuration Options

### 1. ProjectConfig

Controls how Cosmos finds and parses your dbt project.

```python
from cosmos import ProjectConfig

project_config = ProjectConfig(
    # Required: Path to dbt project
    dbt_project_path="/path/to/dbt/project",
    
    # Optional: Relative paths within project
    models_relative_path="models",         # Default: "models"
    seeds_relative_path="seeds",           # Default: "seeds"
    snapshots_relative_path="snapshots",   # Default: "snapshots"
    
    # Optional: Manifest file (for better performance)
    manifest_path="/path/to/target/manifest.json",
    
    # Optional: Select specific models
    select=["tag:daily", "path:marts/finance"],
    exclude=["tag:deprecated"],
    
    # Optional: Project name override
    project_name="my_dbt_project",
)
```

---

### 2. ProfileConfig

Defines how to connect to your data warehouse.

```python
from cosmos import ProfileConfig
from cosmos.profiles import (
    SnowflakeUserPasswordProfileMapping,
    BigQueryProfileMapping,
    RedshiftProfileMapping,
    PostgresProfileMapping,
)

# Snowflake
profile_config = ProfileConfig(
    profile_name="default",
    target_name="prod",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_default",
        profile_args={
            "database": "analytics_db",
            "schema": "analytics",
            "warehouse": "transforming",
            "role": "transformer",
            "threads": 4,
        }
    ),
)

# BigQuery
profile_config = ProfileConfig(
    profile_name="default",
    target_name="prod",
    profile_mapping=BigQueryProfileMapping(
        conn_id="bigquery_default",
        profile_args={
            "dataset": "analytics",
            "project": "my-gcp-project",
            "threads": 4,
            "location": "US",
        }
    ),
)

# Redshift
profile_config = ProfileConfig(
    profile_name="default",
    target_name="prod",
    profile_mapping=RedshiftProfileMapping(
        conn_id="redshift_default",
        profile_args={
            "schema": "analytics",
            "threads": 4,
        }
    ),
)

# Postgres
profile_config = ProfileConfig(
    profile_name="default",
    target_name="prod",
    profile_mapping=PostgresProfileMapping(
        conn_id="postgres_default",
        profile_args={
            "schema": "analytics",
            "threads": 4,
        }
    ),
)
```

---

### 3. ExecutionConfig

Controls how dbt commands are executed.

```python
from cosmos import ExecutionConfig
from cosmos.constants import ExecutionMode

execution_config = ExecutionConfig(
    # Execution mode (local, docker, kubernetes, etc.)
    execution_mode=ExecutionMode.LOCAL,
    
    # Path to dbt executable
    dbt_executable_path="/usr/local/bin/dbt",
    
    # Project directory for execution
    project_dir="/usr/local/airflow/dbt/my_dbt_project",
)
```

---

### 4. RenderConfig

Controls how Cosmos renders your dbt project into Airflow tasks.

```python
from cosmos import RenderConfig
from cosmos.constants import TestBehavior

render_config = RenderConfig(
    # How to handle dbt tests
    test_behavior=TestBehavior.AFTER_EACH,  # or AFTER_ALL, NONE
    
    # Load method (automatic, custom, manifest)
    load_method=LoadMode.AUTOMATIC,
    
    # Select models to render
    select=["tag:daily"],
    exclude=["tag:deprecated"],
    
    # Enable source rendering
    emit_datasets=True,
)
```

---

## 📊 Execution Modes

Cosmos supports multiple execution modes for running dbt commands.

### 1. Local Execution Mode (Default)

Runs dbt directly on the Airflow worker.

```python
from cosmos import ExecutionConfig, ExecutionMode

execution_config = ExecutionConfig(
    execution_mode=ExecutionMode.LOCAL,
)

# Pros:
# ✅ Fastest execution
# ✅ No containerization overhead
# ✅ Simple setup

# Cons:
# ❌ dbt must be installed on Airflow workers
# ❌ Dependency conflicts possible
# ❌ Less isolation
```

---

### 2. Docker Execution Mode

Runs dbt in Docker containers.

```python
from cosmos import ExecutionConfig, ExecutionMode

execution_config = ExecutionConfig(
    execution_mode=ExecutionMode.DOCKER,
    docker_image="my-company/dbt-docker:1.0.0",
)

# Pros:
# ✅ Isolated environment
# ✅ Consistent dependencies
# ✅ Easy version management

# Cons:
# ❌ Slower than local
# ❌ Requires Docker on workers
# ❌ Image building/maintenance
```

**Docker Image Example:**
```dockerfile
# Dockerfile for dbt
FROM python:3.11-slim

# Install dbt
RUN pip install dbt-snowflake==1.7.0

# Copy dbt project
COPY dbt/ /usr/app/dbt/
WORKDIR /usr/app/dbt

# Set entrypoint
ENTRYPOINT ["dbt"]
```

---

### 3. Kubernetes Execution Mode

Runs dbt in Kubernetes pods.

```python
from cosmos import ExecutionConfig, ExecutionMode

execution_config = ExecutionConfig(
    execution_mode=ExecutionMode.KUBERNETES,
    kubernetes_namespace="airflow",
    kubernetes_image="my-company/dbt-k8s:1.0.0",
)

# Pros:
# ✅ Highly scalable
# ✅ Resource isolation
# ✅ Works with KubernetesExecutor

# Cons:
# ❌ Most complex setup
# ❌ Overhead for pod creation
# ❌ Requires K8s cluster
```

---

### 4. dbt Cloud Execution Mode

Runs dbt via dbt Cloud API.

```python
from cosmos import ExecutionConfig, ExecutionMode

execution_config = ExecutionConfig(
    execution_mode=ExecutionMode.DBT_CLOUD,
    dbt_cloud_account_id=12345,
    dbt_cloud_job_id=67890,
)

# Pros:
# ✅ Managed dbt infrastructure
# ✅ Built-in IDE and docs
# ✅ No local setup needed

# Cons:
# ❌ Requires dbt Cloud subscription
# ❌ Less control over execution
# ❌ API rate limits
```

---

## 🔧 Advanced Patterns

### 1. Selective Model Execution

```python
# Run only specific models/tags
dbt_tg = DbtTaskGroup(
    group_id="finance_models_only",
    project_config=ProjectConfig(
        dbt_project_path="/path/to/dbt/project",
        select=["tag:finance", "path:marts/finance"],
        exclude=["tag:deprecated"],
    ),
    profile_config=profile_config,
)

# Run models based on Airflow variables
from airflow.models import Variable

selected_models = Variable.get("dbt_models_to_run", default_var="tag:daily")

dbt_tg = DbtTaskGroup(
    group_id="dynamic_models",
    project_config=ProjectConfig(
        dbt_project_path="/path/to/dbt/project",
        select=[selected_models],
    ),
    profile_config=profile_config,
)
```

---

### 2. Test Configuration

```python
from cosmos import RenderConfig
from cosmos.constants import TestBehavior

# Test after each model
render_config = RenderConfig(
    test_behavior=TestBehavior.AFTER_EACH,
)

# Test after all models complete
render_config = RenderConfig(
    test_behavior=TestBehavior.AFTER_ALL,
)

# Don't run tests
render_config = RenderConfig(
    test_behavior=TestBehavior.NONE,
)

# Usage in DAG
dbt_tg = DbtTaskGroup(
    group_id="dbt_with_tests",
    project_config=project_config,
    profile_config=profile_config,
    render_config=render_config,
)
```

---

### 3. Incremental Models with Full Refresh

```python
from airflow import DAG
from airflow.operators.python import BranchPythonOperator
from cosmos import DbtTaskGroup
from datetime import datetime

def decide_refresh_mode(**context):
    """Decide whether to do full refresh based on day of week"""
    execution_date = context['execution_date']
    if execution_date.weekday() == 6:  # Sunday
        return 'dbt_full_refresh'
    return 'dbt_incremental'

with DAG(
    dag_id="dbt_conditional_refresh",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:
    
    branch = BranchPythonOperator(
        task_id='decide_refresh_mode',
        python_callable=decide_refresh_mode,
    )
    
    # Incremental run
    dbt_incremental = DbtTaskGroup(
        group_id="dbt_incremental",
        project_config=ProjectConfig(
            dbt_project_path="/path/to/dbt/project",
        ),
        profile_config=profile_config,
        operator_args={
            "full_refresh": False,
        },
    )
    
    # Full refresh run
    dbt_full_refresh = DbtTaskGroup(
        group_id="dbt_full_refresh",
        project_config=ProjectConfig(
            dbt_project_path="/path/to/dbt/project",
        ),
        profile_config=profile_config,
        operator_args={
            "full_refresh": True,
        },
    )
    
    branch >> [dbt_incremental, dbt_full_refresh]
```

---

### 4. Environment-Based Configuration

```python
from airflow import DAG
from airflow.models import Variable
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping

# Get environment from Airflow Variable
environment = Variable.get("environment", default_var="dev")

# Environment-specific configuration
env_config = {
    "dev": {
        "conn_id": "snowflake_dev",
        "database": "dev_db",
        "schema": "dev_analytics",
        "warehouse": "dev_wh",
    },
    "staging": {
        "conn_id": "snowflake_staging",
        "database": "staging_db",
        "schema": "staging_analytics",
        "warehouse": "staging_wh",
    },
    "prod": {
        "conn_id": "snowflake_prod",
        "database": "prod_db",
        "schema": "analytics",
        "warehouse": "prod_wh",
    },
}

config = env_config[environment]

with DAG(
    dag_id=f"dbt_pipeline_{environment}",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:
    
    dbt_tg = DbtTaskGroup(
        group_id="dbt_transformation",
        project_config=ProjectConfig(
            dbt_project_path="/path/to/dbt/project",
        ),
        profile_config=ProfileConfig(
            profile_name="default",
            target_name=environment,
            profile_mapping=SnowflakeUserPasswordProfileMapping(
                conn_id=config["conn_id"],
                profile_args={
                    "database": config["database"],
                    "schema": config["schema"],
                    "warehouse": config["warehouse"],
                }
            ),
        ),
    )
```

---

### 5. Pre/Post dbt Hooks

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.slack.operators.slack import SlackAPIPostOperator
from cosmos import DbtTaskGroup
from datetime import datetime

def pre_dbt_validation(**context):
    """Validate data sources before dbt run"""
    # Check if source tables exist
    # Validate row counts
    # Check data freshness
    print("Running pre-dbt validation...")
    return True

def post_dbt_notification(**context):
    """Send notification after dbt run"""
    ti = context['ti']
    dag_run = context['dag_run']
    print(f"dbt run completed for {dag_run.run_id}")
    return True

with DAG(
    dag_id="dbt_with_hooks",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:
    
    pre_validation = PythonOperator(
        task_id="pre_dbt_validation",
        python_callable=pre_dbt_validation,
    )
    
    dbt_tg = DbtTaskGroup(
        group_id="dbt_transformation",
        project_config=ProjectConfig(
            dbt_project_path="/path/to/dbt/project",
        ),
        profile_config=profile_config,
    )
    
    post_notification = PythonOperator(
        task_id="post_dbt_notification",
        python_callable=post_dbt_notification,
    )
    
    slack_alert = SlackAPIPostOperator(
        task_id="slack_notification",
        slack_conn_id="slack_default",
        text="✅ dbt pipeline completed successfully!",
        channel="#data-alerts",
    )
    
    pre_validation >> dbt_tg >> post_notification >> slack_alert
```

---

### 6. Parallel dbt Project Execution

```python
from airflow import DAG
from cosmos import DbtTaskGroup, ProjectConfig
from datetime import datetime

with DAG(
    dag_id="parallel_dbt_execution",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
    max_active_runs=1,
) as dag:
    
    # Multiple independent dbt projects run in parallel
    staging_tg = DbtTaskGroup(
        group_id="staging",
        project_config=ProjectConfig(
            dbt_project_path="/path/to/staging/project",
        ),
        profile_config=profile_config,
    )
    
    raw_processing_tg = DbtTaskGroup(
        group_id="raw_processing",
        project_config=ProjectConfig(
            dbt_project_path="/path/to/raw/project",
        ),
        profile_config=profile_config,
    )
    
    external_data_tg = DbtTaskGroup(
        group_id="external_data",
        project_config=ProjectConfig(
            dbt_project_path="/path/to/external/project",
        ),
        profile_config=profile_config,
    )
    
    # All run in parallel, then converge
    marts_tg = DbtTaskGroup(
        group_id="marts",
        project_config=ProjectConfig(
            dbt_project_path="/path/to/marts/project",
        ),
        profile_config=profile_config,
    )
    
    [staging_tg, raw_processing_tg, external_data_tg] >> marts_tg
```

---

## 💡 Best Practices

### 1. 🎯 DAG Organization

```python
# ✅ GOOD: Organized by business domain
dags/
├── finance/
│   ├── dbt_finance_daily.py
│   └── dbt_finance_monthly.py
├── marketing/
│   ├── dbt_marketing_hourly.py
│   └── dbt_marketing_daily.py
└── operations/
    └── dbt_operations_daily.py

# ❌ BAD: Single monolithic DAG
dags/
└── dbt_everything.py
```

---

### 2. ⚡ Performance Optimization

```python
# Use manifest.json for better performance
project_config = ProjectConfig(
    dbt_project_path="/path/to/dbt/project",
    manifest_path="/path/to/dbt/project/target/manifest.json",
)

# Pros:
# ✅ Faster DAG parsing (no need to parse dbt project)
# ✅ Reduced scheduler load
# ✅ Better for large dbt projects

# Cons:
# ❌ Must generate manifest before deploying
# ❌ Need to update manifest when dbt changes
```

**Generate manifest in CI/CD:**
```bash
# In your deployment pipeline
cd /path/to/dbt/project
dbt compile
cp target/manifest.json /airflow/manifests/
```

---

### 3. 🔐 Secrets Management

```python
# ✅ GOOD: Use Airflow Connections
profile_config = ProfileConfig(
    profile_name="default",
    target_name="prod",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_prod",  # Stored in Airflow
    ),
)

# ✅ GOOD: Use environment variables for non-sensitive config
from os import getenv

database = getenv("DBT_DATABASE", "analytics_db")

# ❌ BAD: Hardcode credentials
profile_args = {
    "user": "my_user",  # Don't do this!
    "password": "my_password",  # Never do this!
}
```

---

### 4. 📊 Monitoring and Alerting

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.trigger_rule import TriggerRule
from cosmos import DbtTaskGroup

def send_failure_alert(**context):
    """Send alert on dbt failure"""
    # Get failed task info
    task_instance = context['task_instance']
    dag_id = context['dag'].dag_id
    
    # Send to monitoring system
    print(f"ALERT: dbt task {task_instance.task_id} failed in {dag_id}")
    
    # Could integrate with:
    # - Slack
    # - PagerDuty
    # - DataDog
    # - Custom webhook

default_args = {
    "owner": "data-team",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "on_failure_callback": send_failure_alert,
}

with DAG(
    dag_id="dbt_with_monitoring",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:
    
    dbt_tg = DbtTaskGroup(
        group_id="dbt_transformation",
        project_config=project_config,
        profile_config=profile_config,
    )
    
    # Run even if dbt fails
    cleanup = PythonOperator(
        task_id="cleanup",
        python_callable=lambda: print("Cleanup complete"),
        trigger_rule=TriggerRule.ALL_DONE,
    )
    
    dbt_tg >> cleanup
```

---

### 5. 🧪 Testing in Development

```python
# dev_dbt_dag.py - For local testing
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping

# Use local dbt installation
execution_config = ExecutionConfig(
    dbt_executable_path="/usr/local/bin/dbt",
)

# Small subset of models
project_config = ProjectConfig(
    dbt_project_path="/path/to/dbt/project",
    select=["tag:dev_test"],
)

# Dev database
profile_config = ProfileConfig(
    profile_name="default",
    target_name="dev",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_dev",
        profile_args={
            "database": "dev_db",
            "schema": "dev_" + os.getenv("USER"),
        }
    ),
)
```

---

### 6. 📝 Documentation

```python
"""
dbt Finance Pipeline
====================

**Purpose**: Daily transformation of financial data

**Schedule**: Daily at 2 AM UTC

**Dependencies**:
- Source: raw.stripe_payments
- Source: raw.quickbooks_invoices
- Upstream: dbt_staging_daily

**Outputs**:
- analytics.fct_revenue
- analytics.dim_customers
- analytics.fct_subscriptions

**SLA**: Complete within 2 hours

**Contacts**:
- Owner: finance-data-team@company.com
- On-Call: data-engineering@company.com

**Runbook**: https://wiki.company.com/dbt-finance-pipeline
"""

from airflow import DAG
from cosmos import DbtTaskGroup
from datetime import datetime, timedelta

# ... rest of DAG definition
```

---

## 📈 Real-World Examples

### Example 1: E-commerce Analytics Pipeline

```python
# dags/ecommerce_analytics_pipeline.py

from datetime import datetime, timedelta
from pathlib import Path

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.providers.slack.operators.slack import SlackAPIPostOperator
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, RenderConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping
from cosmos.constants import TestBehavior

default_args = {
    "owner": "analytics-team",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "email": ["analytics@company.com"],
    "email_on_failure": True,
    "email_on_retry": False,
}

with DAG(
    dag_id="ecommerce_analytics_daily",
    start_date=datetime(2024, 1, 1),
    schedule_interval="0 3 * * *",  # 3 AM UTC daily
    catchup=False,
    default_args=default_args,
    tags=["ecommerce", "analytics", "production"],
    description="Daily e-commerce analytics transformation pipeline",
) as dag:
    
    start = EmptyOperator(task_id="start")
    
    # Staging layer - load and clean raw data
    staging_tg = DbtTaskGroup(
        group_id="staging",
        project_config=ProjectConfig(
            dbt_project_path="/usr/local/airflow/dbt/ecommerce",
            select=["tag:staging"],
        ),
        profile_config=ProfileConfig(
            profile_name="default",
            target_name="prod",
            profile_mapping=SnowflakeUserPasswordProfileMapping(
                conn_id="snowflake_prod",
                profile_args={
                    "database": "analytics_db",
                    "schema": "staging",
                    "warehouse": "transforming_l",
                }
            ),
        ),
        render_config=RenderConfig(
            test_behavior=TestBehavior.AFTER_EACH,
        ),
        operator_args={
            "install_deps": True,
            "full_refresh": False,
        },
    )
    
    # Intermediate layer - business logic
    intermediate_tg = DbtTaskGroup(
        group_id="intermediate",
        project_config=ProjectConfig(
            dbt_project_path="/usr/local/airflow/dbt/ecommerce",
            select=["tag:intermediate"],
        ),
        profile_config=ProfileConfig(
            profile_name="default",
            target_name="prod",
            profile_mapping=SnowflakeUserPasswordProfileMapping(
                conn_id="snowflake_prod",
                profile_args={
                    "database": "analytics_db",
                    "schema": "intermediate",
                    "warehouse": "transforming_xl",
                }
            ),
        ),
        render_config=RenderConfig(
            test_behavior=TestBehavior.AFTER_ALL,
        ),
    )
    
    # Marts layer - business-facing tables
    marts_tg = DbtTaskGroup(
        group_id="marts",
        project_config=ProjectConfig(
            dbt_project_path="/usr/local/airflow/dbt/ecommerce",
            select=["tag:marts"],
        ),
        profile_config=ProfileConfig(
            profile_name="default",
            target_name="prod",
            profile_mapping=SnowflakeUserPasswordProfileMapping(
                conn_id="snowflake_prod",
                profile_args={
                    "database": "analytics_db",
                    "schema": "analytics",
                    "warehouse": "transforming_xl",
                }
            ),
        ),
        render_config=RenderConfig(
            test_behavior=TestBehavior.AFTER_ALL,
        ),
    )
    
    # Success notification
    success_notification = SlackAPIPostOperator(
        task_id="success_notification",
        slack_conn_id="slack_data_alerts",
        text="✅ E-commerce analytics pipeline completed successfully!",
        channel="#data-alerts",
    )
    
    # Define dependencies
    start >> staging_tg >> intermediate_tg >> marts_tg >> success_notification
```

---

### Example 2: Real-Time Events Pipeline

```python
# dags/events_pipeline_hourly.py

from datetime import datetime, timedelta
from airflow import DAG
from airflow.sensors.external_task import ExternalTaskSensor
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig
from cosmos.profiles import BigQueryProfileMapping

with DAG(
    dag_id="events_pipeline_hourly",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@hourly",
    catchup=False,
    max_active_runs=3,  # Allow multiple runs
    tags=["events", "real-time", "hourly"],
) as dag:
    
    # Wait for upstream data ingestion
    wait_for_ingestion = ExternalTaskSensor(
        task_id="wait_for_ingestion",
        external_dag_id="fivetran_events_sync",
        external_task_id="sync_complete",
        timeout=3600,
        poke_interval=60,
    )
    
    # Process hourly events
    events_tg = DbtTaskGroup(
        group_id="process_events",
        project_config=ProjectConfig(
            dbt_project_path="/usr/local/airflow/dbt/events",
            select=["tag:hourly", "tag:events"],
        ),
        profile_config=ProfileConfig(
            profile_name="default",
            target_name="prod",
            profile_mapping=BigQueryProfileMapping(
                conn_id="bigquery_prod",
                profile_args={
                    "dataset": "events_processed",
                    "project": "my-gcp-project",
                    "threads": 8,
                }
            ),
        ),
        operator_args={
            "vars": {
                "event_hour": "{{ execution_date.strftime('%Y-%m-%d %H:00:00') }}",
            },
        },
    )
    
    wait_for_ingestion >> events_tg
```

---

### Example 3: Multi-Warehouse Pipeline

```python
# dags/multi_warehouse_pipeline.py

from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig
from cosmos.profiles import (
    SnowflakeUserPasswordProfileMapping,
    BigQueryProfileMapping,
)

def cross_warehouse_validation(**context):
    """Validate data consistency across warehouses"""
    # Compare row counts, key metrics
    print("Validating cross-warehouse consistency...")
    return True

with DAG(
    dag_id="multi_warehouse_sync",
    start_date=datetime(2024, 1, 1),
    schedule_interval="0 4 * * *",  # 4 AM daily
    catchup=False,
) as dag:
    
    # Transform data in Snowflake
    snowflake_tg = DbtTaskGroup(
        group_id="snowflake_transformation",
        project_config=ProjectConfig(
            dbt_project_path="/usr/local/airflow/dbt/snowflake_project",
        ),
        profile_config=ProfileConfig(
            profile_name="default",
            target_name="prod",
            profile_mapping=SnowflakeUserPasswordProfileMapping(
                conn_id="snowflake_prod",
                profile_args={
                    "database": "analytics_db",
                    "schema": "analytics",
                }
            ),
        ),
    )
    
    # Replicate to BigQuery for BI tools
    bigquery_tg = DbtTaskGroup(
        group_id="bigquery_replication",
        project_config=ProjectConfig(
            dbt_project_path="/usr/local/airflow/dbt/bigquery_project",
        ),
        profile_config=ProfileConfig(
            profile_name="default",
            target_name="prod",
            profile_mapping=BigQueryProfileMapping(
                conn_id="bigquery_prod",
                profile_args={
                    "dataset": "analytics_replica",
                    "project": "my-gcp-project",
                }
            ),
        ),
    )
    
    # Validate consistency
    validation = PythonOperator(
        task_id="cross_warehouse_validation",
        python_callable=cross_warehouse_validation,
    )
    
    snowflake_tg >> bigquery_tg >> validation
```

---

### Example 4: Incremental with Weekly Full Refresh

```python
# dags/incremental_with_full_refresh.py

from datetime import datetime
from airflow import DAG
from airflow.operators.python import BranchPythonOperator
from airflow.operators.empty import EmptyOperator
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig

def choose_run_type(**context):
    """Full refresh on Sunday, incremental other days"""
    execution_date = context['execution_date']
    if execution_date.weekday() == 6:  # Sunday
        return 'full_refresh_group'
    return 'incremental_group'

with DAG(
    dag_id="smart_incremental_pipeline",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:
    
    branch = BranchPythonOperator(
        task_id='choose_run_type',
        python_callable=choose_run_type,
    )
    
    # Incremental run (Mon-Sat)
    incremental_tg = DbtTaskGroup(
        group_id="incremental_group",
        project_config=ProjectConfig(
            dbt_project_path="/usr/local/airflow/dbt/my_project",
            select=["tag:incremental"],
        ),
        profile_config=profile_config,
        operator_args={
            "full_refresh": False,
        },
    )
    
    # Full refresh (Sunday)
    full_refresh_tg = DbtTaskGroup(
        group_id="full_refresh_group",
        project_config=ProjectConfig(
            dbt_project_path="/usr/local/airflow/dbt/my_project",
            select=["tag:incremental"],
        ),
        profile_config=profile_config,
        operator_args={
            "full_refresh": True,
        },
    )
    
    # Converge back
    end = EmptyOperator(
        task_id='end',
        trigger_rule='none_failed_min_one_success',
    )
    
    branch >> [incremental_tg, full_refresh_tg] >> end
```

---

## 🔍 Troubleshooting

### Issue 1: DAG Not Appearing in Airflow UI

**Symptoms:** DAG file exists but doesn't show up in UI

**Solutions:**

1. **Check DAG parsing errors**
```bash
airflow dags list-import-errors
```

2. **Validate Python syntax**
```bash
python /path/to/dag/file.py
```

3. **Check Airflow logs**
```bash
tail -f $AIRFLOW_HOME/logs/scheduler/latest/*.log
```

4. **Ensure dbt project path is correct**
```python
# Use absolute paths
dbt_project_path = Path(__file__).parent.parent / "dbt" / "my_project"

# Verify path exists
assert dbt_project_path.exists(), f"dbt project not found at {dbt_project_path}"
```

---

### Issue 2: Connection Errors

**Error:** `Connection 'snowflake_default' not found`

**Solutions:**

1. **Create connection in Airflow UI**
```
Admin -> Connections -> Add Connection
- Conn ID: snowflake_default
- Conn Type: Snowflake
- Login: your_username
- Password: your_password
- Extra: {"account": "xy12345", "warehouse": "transforming", ...}
```

2. **Or set via environment variable**
```bash
export AIRFLOW_CONN_SNOWFLAKE_DEFAULT='{"conn_type": "snowflake", ...}'
```

3. **Test connection**
```python
from airflow.hooks.base import BaseHook

conn = BaseHook.get_connection("snowflake_default")
print(conn.host, conn.login)
```

---

### Issue 3: dbt Command Not Found

**Error:** `dbt: command not found`

**Solutions:**

1. **Ensure dbt is installed in Airflow environment**
```bash
# In Airflow worker/scheduler environment
pip install dbt-snowflake  # or dbt-bigquery, etc.
```

2. **Specify dbt executable path**
```python
execution_config = ExecutionConfig(
    dbt_executable_path="/usr/local/bin/dbt",  # Full path
)
```

3. **Or use Docker/Kubernetes execution mode**
```python
execution_config = ExecutionConfig(
    execution_mode=ExecutionMode.DOCKER,
    docker_image="my-dbt-image:latest",
)
```

---

### Issue 4: Manifest Parsing Errors

**Error:** `Unable to parse manifest.json`

**Solutions:**

1. **Generate fresh manifest**
```bash
cd /path/to/dbt/project
dbt compile
```

2. **Don't use manifest in development**
```python
# Remove or comment out
# manifest_path="/path/to/manifest.json"
```

3. **Ensure manifest version matches dbt version**

---

### Issue 5: Task Dependencies Not Correct

**Problem:** Tasks run in wrong order or all at once

**Solutions:**

1. **Check dbt project for circular dependencies**
```bash
dbt compile --select model_name
dbt list --select model_name+ --output json
```

2. **Verify ref() and source() usage in models**

3. **Use Airflow UI to visualize task graph**

---

### Issue 6: Slow DAG Parsing

**Problem:** Airflow UI slow to load, high scheduler CPU

**Solutions:**

1. **Use manifest.json**
```python
project_config = ProjectConfig(
    dbt_project_path="/path/to/dbt/project",
    manifest_path="/path/to/dbt/project/target/manifest.json",
)
```

2. **Reduce model selection**
```python
project_config = ProjectConfig(
    dbt_project_path="/path/to/dbt/project",
    select=["tag:critical"],  # Only critical models
)
```

3. **Increase Airflow DAG parsing interval**
```python
# airflow.cfg
[scheduler]
dag_dir_list_interval = 300  # Parse every 5 minutes instead of default
```

---

### Issue 7: Permission Denied Errors

**Error:** `Permission denied: '/usr/local/airflow/dbt/my_project'`

**Solutions:**

1. **Fix file permissions**
```bash
chmod -R 755 /usr/local/airflow/dbt
chown -R airflow:airflow /usr/local/airflow/dbt
```

2. **Use appropriate user in Docker**
```yaml
# docker-compose.yml
services:
  airflow-worker:
    user: "50000:50000"  # Match with volume permissions
```

---

## 📚 Quick Reference

### Cosmos Imports

```python
from cosmos import (
    DbtDag,              # Standalone dbt DAG
    DbtTaskGroup,        # dbt as TaskGroup
    ProjectConfig,       # dbt project configuration
    ProfileConfig,       # Connection configuration
    ExecutionConfig,     # How to run dbt
    RenderConfig,        # How to render tasks
)

from cosmos.profiles import (
    SnowflakeUserPasswordProfileMapping,
    BigQueryProfileMapping,
    RedshiftProfileMapping,
    PostgresProfileMapping,
)

from cosmos.constants import (
    ExecutionMode,       # LOCAL, DOCKER, KUBERNETES
    TestBehavior,        # AFTER_EACH, AFTER_ALL, NONE
    LoadMode,            # AUTOMATIC, CUSTOM, DBT_LS, DBT_MANIFEST
)
```

---

### Common Configuration Patterns

```python
# Basic DbtDag
my_dag = DbtDag(
    dag_id="my_dbt_dag",
    project_config=ProjectConfig(...),
    profile_config=ProfileConfig(...),
)

# DbtTaskGroup in existing DAG
with DAG(...) as dag:
    dbt_tg = DbtTaskGroup(
        group_id="dbt_group",
        project_config=ProjectConfig(...),
        profile_config=ProfileConfig(...),
    )

# Selective execution
project_config = ProjectConfig(
    dbt_project_path="...",
    select=["tag:daily", "path:marts"],
    exclude=["tag:deprecated"],
)

# With tests
render_config = RenderConfig(
    test_behavior=TestBehavior.AFTER_EACH,
)

# With manifest
project_config = ProjectConfig(
    dbt_project_path="...",
    manifest_path=".../target/manifest.json",
)
```

---

## 🚀 Deployment Checklist

```markdown
## Pre-Deployment

- [ ] dbt project compiles successfully locally
- [ ] All dbt tests pass
- [ ] Airflow connections configured
- [ ] dbt profiles configured correctly
- [ ] Environment variables set
- [ ] Cosmos installed with correct adapters
- [ ] Scheduler has access to dbt project files
- [ ] Workers have access to dbt project files (if distributed)

## Deployment

- [ ] Deploy dbt project to Airflow environment
- [ ] Deploy DAG files
- [ ] Generate and deploy manifest.json (if using)
- [ ] Restart Airflow scheduler
- [ ] Verify DAG appears in UI
- [ ] Run test execution with short model selection
- [ ] Check task logs for errors
- [ ] Verify task dependencies in graph view

## Post-Deployment

- [ ] Monitor first full DAG run
- [ ] Set up alerting
- [ ] Document runbooks
- [ ] Share with team
- [ ] Schedule review after 1 week
```

---

<div align="center">

### 🎯 Key Takeaways

![Takeaway 1](https://img.shields.io/badge/💡_Zero_Code-Auto_DAG_Generation-4CAF50?style=for-the-badge)
![Takeaway 2](https://img.shields.io/badge/💡_Native_Airflow-Full_Observability-2196F3?style=for-the-badge)
![Takeaway 3](https://img.shields.io/badge/💡_Production_Ready-Battle_Tested-9C27B0?style=for-the-badge)

**Remember**: Cosmos bridges dbt and Airflow - best of both worlds!

</div>

---

## 📖 Additional Resources

- **Cosmos Documentation**: https://astronomer.github.io/astronomer-cosmos/
- **Cosmos GitHub**: https://github.com/astronomer/astronomer-cosmos
- **Airflow Documentation**: https://airflow.apache.org/docs/
- **dbt Documentation**: https://docs.getdbt.com/
- **Astronomer Blog**: https://www.astronomer.io/blog/

---

*Note: This guide is based on Cosmos 1.x. Features and APIs may change in future versions. Always refer to the official documentation for the most up-to-date information.*
