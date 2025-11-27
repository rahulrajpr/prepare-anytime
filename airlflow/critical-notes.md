### Scheduled Tags

| Schedule Tag           | When It's Triggered                     | What Data It Processes                        | Simple Example                                           |
| ---------------------- | --------------------------------------- | --------------------------------------------- | -------------------------------------------------------- |
| **`@hourly`**  | At the**start of the next hour**  | Data from the**previous hour**          | Run at**2:00 PM**to process 1:00 PM - 2:00 PM data |
| **`@daily`**   | Just after**midnight**            | Data from the**previous day**           | Run at**Jan 2, 00:00**to process all of Jan 1      |
| **`@weekly`**  | Just after**midnight on Sunday**  | Data from the**previous week**(Mon-Sun) | Run on**Monday, 00:00**to process last week's data |
| **`@monthly`** | Just after**midnight on the 1st** | Data from the**previous month**         | Run on**Feb 1, 00:00**to process all of January    |
| **`@yearly`**  | Just after**midnight on Jan 1st** | Data from the**previous year**          | Run on**Jan 1, 2025**to process all of 2024        |

Note :

Airflow  **always runs after a time period has finished** . It processes the data from that completed period.

**python**

```
start_date = datetime(2025,10,10,1,0,0) # Oct 10, 2025, 1:00 AM
schedule_interval = '@hourly'
```

**What Happens:**
The first run will process data from **1:00 AM to 2:00 AM** and will start executing just after  **2:00 AM**

### **XComs**

**What it is:** XCom (Cross-Communication) is Airflow's way for tasks to **share small pieces of data** with each other.

**How it works:** One task **pushes** data, another task **pulls** it.

```
def push_function(**context):
    # Push data to XCom
    context['ti'].xcom_push(key='filename', value='my_data.csv')

def pull_function(**context):
    # Pull data from XCom
    filename = context['ti'].xcom_pull(task_ids='push_task', key='filename')
    print(f"Processing file: {filename}")

push_task = PythonOperator(
    task_id='push_task',
    python_callable=push_function
)

pull_task = PythonOperator(
    task_id='pull_task',
    python_callable=pull_function
)

push_task >> pull_task
```

### **Key Points:**

* ✅ **Use for:** Small data (file paths, IDs, counts, status messages)
* ❌ **Don't use for:** Large data (dataframes, files, datasets)
* **Automatically returns:** The last line of a Python function is auto-pushed
* **Storage:** Saved in Airflow's database

**In short:** XComs let Task A pass a note to Task B.

### **Executors** 

**What it is:** The executor decides  **how and where your tasks run** .

### **Executor Comparison**

| Executor                     | Key Description                   | Parallel Tasks?            | Best For                        | Production Ready? | Setup Complexity |
| ---------------------------- | --------------------------------- | -------------------------- | ------------------------------- | ----------------- | ---------------- |
| **SequentialExecutor** | "One task at a time"              | ❌ No                      | Testing, SQLite                 | ❌ No             | Easiest          |
| **LocalExecutor**      | "Many tasks on one machine"       | ✅ Yes (single machine)    | Small workloads, Development    | ✅ Small scale    | Easy             |
| **CeleryExecutor**     | "Many tasks across many machines" | ✅ Yes (multiple machines) | Large production workloads      | ✅ Yes            | Complex          |
| **KubernetesExecutor** | "One task, one container"         | ✅ Yes (containers)        | Cloud-native, dynamic workloads | ✅ Yes            | Most Complex     |

### **Key Points:**

* **Start with:** LocalExecutor for development
* **Production choice:** CeleryExecutor (traditional) or KubernetesExecutor (cloud-native)
* **Avoid:** SequentialExecutor except for basic testing

**In short:** Executor = Task runner. Choose based on your scale and infrastructure needs.

### Airflow Retries

Retries automatically re-run a task if it fails, handling temporary errors like network issues or API timeouts.

**Where to set:**

* **DAG level** : Default for all tasks
* **Task level** : Overrides DAG default

**Key arguments:**

* `retries`: Number of retry attempts (e.g., `retries=3`)
* `retry_delay`: Wait time between retries (e.g., `timedelta(minutes=5)`)
* `retry_exponential_backoff`: Increase delay exponentially
* `max_retry_delay`: Maximum delay time

**Example:** 

**python**

```
default_args = {
    'retries': 3,  # All tasks get 3 retries
    'retry_delay': timedelta(minutes=5)
}

# Inherits DAG retries (3 attempts, 5-min delay)
task1 = PythonOperator(task_id='task1', ...)

# Overrides with own settings (1 attempt, 10-min delay)  
task2 = PythonOperator(
    task_id='task2',
    retries=1,
    retry_delay=timedelta(minutes=10)
)
```

**Key point:** Task-level settings override DAG-level settings.

**SLA (Service Level Agreement):**

**What:** Maximum allowed time for a task/DAG to complete
**For:** Mainly set at **task level** (can be set at DAG level too)

**How to set:**

**python**

```
task = PythonOperator(
    task_id='my_task',
    sla=timedelta(hours=2)  # Must finish within 2 hours
)
```

**SLA Miss Callback Example:**

**python**

```
def sla_miss_alert(dag, task_list, blocking_task_list, slas, blocking_tis):
    print(f"SLA missed in DAG: {dag.dag_id}")
    print(f"Tasks that missed SLA: {task_list}")
    # Add your alert logic here (Slack, email, etc.)

with DAG(
    dag_id='my_dag',
    sla_miss_callback=sla_miss_alert,  # Assign callback
    ...
) as dag:
    # Your tasks here
```

**Notifications:**

* Airflow **automatically** sends email alerts when SLA is missed
* Appears in Airflow UI as "SLA Missed"
* Custom alerts via `sla_miss_callback`

**Key point:** SLA monitors if tasks finish within expected time, triggers alerts automatically when breached.
