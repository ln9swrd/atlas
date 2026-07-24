# Forge Data Model

## 1. Purpose

This document defines the data model used by Forge.

Forge requires structured data to maintain:

* Production tasks
* Asset information
* Execution history
* Validation results
* Runtime knowledge

The data model supports both small-scale development and future production expansion.

---

# 2. Storage Strategy

Forge uses a layered storage approach.

```text
Development Stage

Git Files
(JSON / Markdown)

↓

Runtime Stage

PostgreSQL Database

↓

Production Stage

Distributed Asset Knowledge System
```

---

# 3. Core Data Entities

Forge manages the following entities:

```text
Forge

├── Project

├── Task

├── Asset

├── Execution

├── Validation

├── Environment

└── Event
```

---

# 4. Project Entity

## Purpose

Represents a production project.

Example:

```json
{
  "project_id": "excelion",
  "name": "Excelion",
  "type": "game_ip",
  "status": "active"
}
```

Fields:

| Field      | Description       |
| ---------- | ----------------- |
| project_id | Unique identifier |
| name       | Project name      |
| status     | Lifecycle state   |
| created_at | Creation time     |
| updated_at | Last update       |

---

# 5. Task Entity

## Purpose

Represents an executable production task.

Example:

```json
{
  "task_id": "EX-BRAVE-029",
  "type": "modeling",
  "status": "running"
}
```

Fields:

| Field       | Description          |
| ----------- | -------------------- |
| task_id     | Task identifier      |
| project_id  | Related project      |
| objective   | Task goal            |
| environment | Required environment |
| status      | Execution state      |

---

# 6. Asset Entity

## Purpose

Stores production asset information.

Examples:

* Mecha model
* Weapon
* Animation
* Material

Example:

```json
{
  "asset_id": "brave_frame_v01",
  "type": "mech",
  "version": "0.1"
}
```

Fields:

| Field    | Description      |
| -------- | ---------------- |
| asset_id | Asset identifier |
| name     | Asset name       |
| type     | Asset category   |
| version  | Version          |
| source   | Original source  |
| location | File location    |

---

# 7. Execution Entity

## Purpose

Records actual execution.

Example:

```json
{
  "execution_id": "run-001",
  "task_id": "EX-BRAVE-029",
  "result": "success"
}
```

Fields:

| Field        | Description          |
| ------------ | -------------------- |
| execution_id | Execution identifier |
| task_id      | Related task         |
| environment  | Machine/environment  |
| tool         | Used tool            |
| start_time   | Start                |
| end_time     | End                  |
| result       | Result               |

---

# 8. Validation Entity

## Purpose

Stores verification results.

Example:

```json
{
  "validation_id": "val-001",
  "status": "PASS"
}
```

Fields:

| Field         | Description           |
| ------------- | --------------------- |
| validation_id | Validation identifier |
| execution_id  | Related execution     |
| validator     | Validation system     |
| status        | PASS/FAIL             |
| evidence      | Evidence location     |

---

# 9. Environment Entity

## Purpose

Describes execution capability.

Examples:

```text
DEV_WORK

Blender
Python
Git


DEV_HOME_MAIN

Unreal
GPU
AI
```

Fields:

| Field          | Description      |
| -------------- | ---------------- |
| environment_id | Environment name |
| capability     | Available tools  |
| limitation     | Restrictions     |

---

# 10. Event Entity

## Purpose

Stores execution history.

Examples:

* Task started
* Validation completed
* Error occurred

Example:

```json
{
  "event": "TASK_COMPLETED",
  "source": "Forge"
}
```

---

# 11. PostgreSQL Mapping

Future database structure:

```text
projects

tasks

assets

executions

validations

environments

events
```

Relations:

```text
Project

↓

Task

↓

Execution

↓

Validation

↓

Evidence
```

---

# 12. Evidence Storage

Evidence itself should not always be stored inside database.

Recommended:

Database:

* Metadata
* Status
* Location

File Storage:

* Logs
* Reports
* Generated assets

Example:

```text
PostgreSQL

↓

validation_result.json


Git / Storage

↓

model.fbx

↓

report.txt
```

---

# 13. Data Principles

## Single Source of Truth

Each data type has one owner.

---

## Traceability

Every result can be traced:

```text
Task

↓

Execution

↓

Validation

↓

Evidence
```

---

## Evolution

The model must support:

* Individual development
* Team development
* Large-scale production

---

# Summary

Forge Data Model connects production activity with measurable evidence.

The goal is:

```text
Intent

↓

Task

↓

Execution

↓

Data

↓

Knowledge
```

Forge does not only create assets.

It creates reusable production knowledge.
