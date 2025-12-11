# Apache Airflow Architecture - Study Guide

## 1. What is Apache Airflow?

Apache Airflow is an open-source platform for programmatically authoring, scheduling, and monitoring workflows. It allows you to define workflows as Directed Acyclic Graphs (DAGs) of tasks.

### Key Features
- **Dynamic**: Pipelines are defined in Python, allowing dynamic pipeline generation
- **Extensible**: Easily define your own operators and extend libraries
- **Elegant**: Pipelines are lean and explicit with parameterized scripts
- **Scalable**: Modular architecture with a message queue for orchestration

---

## 2. Core Components Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Web Server                           │
│                    (Flask Application)                      │
│              - UI for monitoring & management               │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────────┐
│                        Scheduler                            │
│              - Parses DAGs                                  │
│              - Schedules task execution                     │
│              - Monitors task states                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────────┐
│                    Metadata Database                        │
│              (PostgreSQL/MySQL/SQLite)                      │
│              - Stores DAG definitions                       │
│              - Task states & execution history              │
│              - User information & connections               │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────────┐
│                        Executor                             │
│              - Executes tasks                               │
│              - Manages worker processes/nodes               │
│              - Types: Sequential, Local, Celery, K8s        │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────────┐
│                         Workers                             │
│              - Execute assigned tasks                       │
│              - Report task status                           │
│              - Can be distributed across machines           │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Component Details

### 3.1 Web Server
**Purpose**: Provides the user interface for Airflow

**Key Functions**:
- Visualize DAGs and their execution history
- Monitor task execution in real-time
- Trigger DAG runs manually
- View logs and task details
- Manage connections, variables, and users

**Technology**: Flask application with Gunicorn web server

**Typical Port**: 8080

### 3.2 Scheduler
**Purpose**: Core component that schedules and monitors DAG execution

**Key Functions**:
1. **DAG Parsing**: 
   - Scans the DAGs folder for new/updated DAG files
   - Parses Python files to extract DAG definitions
   - Updates metadata database with DAG structure

2. **Task Scheduling**:
   - Determines which tasks are ready to run
   - Respects dependencies and schedule intervals
   - Sends tasks to the executor

3. **State Management**:
   - Monitors task execution status
   - Updates task states (queued, running, success, failed)
   - Handles retries and timeouts

**Important**: 
- Should only run ONE scheduler in production (unless using HA setup in Airflow 2.x+)
- Continuously runs in a loop with heartbeat mechanism

### 3.3 Metadata Database
**Purpose**: Persistent storage for all Airflow metadata

**Stores**:
- DAG definitions and versions
- Task instances and their states
- Task execution history and logs references
- Connection credentials (encrypted)
- Variables and configurations
- User accounts and permissions (RBAC)
- SLA misses and statistics

**Supported Databases**:
- PostgreSQL (recommended for production)
- MySQL
- SQLite (development only)

**Key Tables**:
- `dag`: DAG definitions
- `dag_run`: DAG execution instances
- `task_instance`: Individual task executions
- `task_fail`: Failed task records
- `connection`: External system connections
- `variable`: Key-value configurations

### 3.4 Executor
**Purpose**: Defines HOW tasks are executed

**Executor Types**:

#### Sequential Executor (Default)
- Executes tasks one at a time
- Uses SQLite by default
- **Use Case**: Development/testing only
- **Limitation**: Cannot run parallel tasks

#### Local Executor
- Runs tasks in parallel on a single machine
- Uses multiprocessing
- **Use Case**: Small production loads, single machine
- **Configuration**: Set `parallelism` parameter

#### Celery Executor
- Distributes tasks across multiple worker machines
- Uses message broker (RabbitMQ/Redis)
- **Use Case**: Large-scale production, distributed systems
- **Components**:
  - Message Broker: Queues tasks
  - Multiple Workers: Execute tasks
  - Result Backend: Stores task results

#### Kubernetes Executor
- Launches each task in a separate Kubernetes pod
- **Use Case**: Cloud-native deployments, dynamic scaling
- **Benefits**: Resource isolation, auto-scaling

#### Dask Executor
- Distributed computing using Dask
- **Use Case**: Data science workflows

### 3.5 Workers
**Purpose**: Execute the actual task code

**Characteristics**:
- Pull tasks from the executor's queue
- Execute task Python code
- Report status back to scheduler
- Can run on multiple machines (with Celery/K8s)
- Isolated execution environments

---

## 4. DAG (Directed Acyclic Graph)

### What is a DAG?
- Collection of tasks with dependencies
- Defines the execution order
- No cycles allowed (acyclic)
- Represents a workflow

### DAG Definition Example
```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data_team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email': ['alerts@company.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'example_pipeline',
    default_args=default_args,
    description='Example ETL pipeline',
    schedule_interval='0 0 * * *',  # Daily at midnight
    catchup=False,
    tags=['example', 'etl']
)

def extract_data():
    # Extract logic
    pass

def transform_data():
    # Transform logic
    pass

def load_data():
    # Load logic
    pass

extract_task = PythonOperator(
    task_id='extract',
    python_callable=extract_data,
    dag=dag
)

transform_task = PythonOperator(
    task_id='transform',
    python_callable=transform_data,
    dag=dag
)

load_task = PythonOperator(
    task_id='load',
    python_callable=load_data,
    dag=dag
)

# Define dependencies
extract_task >> transform_task >> load_task
```

---

## 5. Task Lifecycle

```
┌──────────┐
│   None   │ (Task not yet scheduled)
└────┬─────┘
     │
     v
┌──────────┐
│ Scheduled│ (Scheduler has scheduled the task)
└────┬─────┘
     │
     v
┌──────────┐
│  Queued  │ (Task sent to executor queue)
└────┬─────┘
     │
     v
┌──────────┐
│ Running  │ (Worker is executing the task)
└────┬─────┘
     │
     ├─────> Success
     ├─────> Failed ────> Up for Retry ────> Scheduled
     └─────> Skipped
```

### Task States
- **None**: Not yet scheduled
- **Scheduled**: Scheduled for execution
- **Queued**: Sent to executor, waiting for worker
- **Running**: Currently executing on worker
- **Success**: Completed successfully
- **Failed**: Execution failed
- **Up for Retry**: Will be retried
- **Skipped**: Skipped due to branching
- **Upstream Failed**: Dependency failed
- **Removed**: No longer in DAG

---

## 6. Airflow Execution Flow

### Step-by-Step Execution

1. **DAG File Creation**
   - Developer writes DAG Python file
   - Saves to `dags_folder` directory

2. **DAG Parsing**
   - Scheduler scans `dags_folder`
   - Parses DAG files (default: every 30 seconds)
   - Updates metadata database

3. **DAG Scheduling**
   - Scheduler creates DagRun based on schedule_interval
   - Evaluates task dependencies
   - Creates TaskInstances for ready tasks

4. **Task Queuing**
   - Scheduler sends tasks to Executor
   - Executor queues tasks for workers

5. **Task Execution**
   - Worker picks up task from queue
   - Executes task code
   - Updates task state in metadata DB

6. **Status Monitoring**
   - Scheduler monitors task completion
   - Updates DAG run status
   - Handles retries for failed tasks

7. **Visualization**
   - Web server queries metadata DB
   - Displays DAG status, logs, metrics

---

## 7. Airflow Configuration

### Key Configuration Files

#### airflow.cfg
Main configuration file with sections:
- **[core]**: Base settings (dags_folder, executor, sql_alchemy_conn)
- **[scheduler]**: Scheduler behavior
- **[webserver]**: Web UI settings
- **[celery]**: Celery executor settings
- **[operators]**: Operator defaults
- **[email]**: SMTP configuration

#### Example Configuration
```ini
[core]
dags_folder = /opt/airflow/dags
executor = CeleryExecutor
sql_alchemy_conn = postgresql+psycopg2://user:pass@localhost/airflow
parallelism = 32
dag_concurrency = 16
max_active_runs_per_dag = 3

[scheduler]
scheduler_heartbeat_sec = 5
dag_dir_list_interval = 300
min_file_process_interval = 30

[celery]
broker_url = redis://localhost:6379/0
result_backend = db+postgresql://user:pass@localhost/airflow
worker_concurrency = 16
```

---

## 8. Operators

Operators define what actually gets done in a task.

### Common Operator Types

#### PythonOperator
Executes Python callable
```python
from airflow.operators.python import PythonOperator

task = PythonOperator(
    task_id='my_task',
    python_callable=my_function,
    op_args=[arg1, arg2],
    dag=dag
)
```

#### BashOperator
Executes bash command
```python
from airflow.operators.bash import BashOperator

task = BashOperator(
    task_id='run_script',
    bash_command='python /path/to/script.py',
    dag=dag
)
```

#### PostgresOperator / MySQLOperator
Executes SQL queries
```python
from airflow.providers.postgres.operators.postgres import PostgresOperator

task = PostgresOperator(
    task_id='create_table',
    postgres_conn_id='my_postgres',
    sql='CREATE TABLE IF NOT EXISTS users (id INT, name VARCHAR(50))',
    dag=dag
)
```

#### EmailOperator
Sends emails
```python
from airflow.operators.email import EmailOperator

task = EmailOperator(
    task_id='send_email',
    to='user@example.com',
    subject='Airflow Report',
    html_content='<p>Report generated successfully</p>',
    dag=dag
)
```

---

## 9. XCom (Cross-Communication)

### Purpose
Allows tasks to exchange small amounts of data

### Usage
```python
def push_data(**context):
    # Push data to XCom
    context['ti'].xcom_push(key='my_key', value='my_value')

def pull_data(**context):
    # Pull data from XCom
    value = context['ti'].xcom_pull(key='my_key', task_ids='push_task')
    print(f"Received: {value}")

push_task = PythonOperator(
    task_id='push_task',
    python_callable=push_data,
    provide_context=True,
    dag=dag
)

pull_task = PythonOperator(
    task_id='pull_task',
    python_callable=pull_data,
    provide_context=True,
    dag=dag
)

push_task >> pull_task
```

### Limitations
- Stored in metadata database
- Should only be used for small data (< 48KB)
- For large data, use external storage (S3, HDFS)

---

## 10. High Availability & Scaling

### Scheduler High Availability (Airflow 2.0+)
- Multiple schedulers can run simultaneously
- Active-active configuration
- Prevents single point of failure

### Scaling Strategies

#### Horizontal Scaling (Celery)
- Add more worker nodes
- Increase worker_concurrency
- Use multiple queues for different task types

#### Vertical Scaling
- Increase parallelism settings
- Optimize task execution time
- Use better hardware for scheduler

#### Database Optimization
- Use connection pooling
- Regular database maintenance
- Proper indexing on metadata tables

---

## 11. Common Interview Questions

### Q1: What happens if the scheduler goes down?
**Answer**: 
- Running tasks continue to execute
- No new tasks are scheduled
- DAG parsing stops
- Web server can still display data (read-only)
- When scheduler restarts, it catches up with missed schedules

### Q2: Difference between start_date and execution_date?
**Answer**:
- **start_date**: Earliest date the DAG can run
- **execution_date**: The logical date/time for which the DAG is running (represents the data interval start)
- Example: DAG scheduled daily at midnight runs on Jan 2 for execution_date Jan 1

### Q3: How does Airflow handle task failures?
**Answer**:
1. Task fails
2. If retries configured, marks task "up_for_retry"
3. Waits for retry_delay
4. Re-schedules task
5. After max retries, marks as "failed"
6. Can trigger email/alerts on failure

### Q4: What's the difference between SequentialExecutor and LocalExecutor?
**Answer**:
- **SequentialExecutor**: Runs one task at a time, uses SQLite, development only
- **LocalExecutor**: Runs multiple tasks in parallel using multiprocessing, requires PostgreSQL/MySQL

### Q5: How does task dependency work?
**Answer**:
- Uses >> and << operators or set_upstream/set_downstream
- Creates edges in DAG
- Scheduler only schedules tasks after all upstream tasks succeed
- Example: `task1 >> task2 >> task3` means task2 waits for task1, task3 waits for task2

---

## 12. Best Practices

1. **Keep DAGs Idempotent**: Tasks should produce same result when run multiple times
2. **Use Variables/Connections**: Don't hardcode credentials
3. **Proper Retry Configuration**: Set appropriate retries and retry_delay
4. **Use Sensors Wisely**: Avoid blocking workers; use poke_interval
5. **Monitor Performance**: Track DAG execution times and success rates
6. **Version Control**: Keep DAG files in Git
7. **Resource Management**: Set proper queue, pool, and priority_weight
8. **Testing**: Test DAGs locally before deploying
9. **Documentation**: Add descriptions and tags to DAGs
10. **Avoid Heavy Computation**: Offload heavy work to external systems

---

## 13. Monitoring & Troubleshooting

### Key Metrics to Monitor
- Scheduler heartbeat
- Task success/failure rate
- DAG execution duration
- Queue size
- Worker availability
- Database connection pool

### Common Issues
1. **Zombie/Undead processes**: Tasks marked running but actually dead
2. **Memory leaks**: Workers consuming too much memory
3. **Database locks**: Too many connections or long transactions
4. **DAG not appearing**: Syntax errors, import errors
5. **Tasks stuck in queued**: Not enough workers or executor issues
