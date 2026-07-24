# Atlas Operations Manual

## 1. Purpose

This document defines the daily operating procedure for Atlas DevOS.

The goal is to make Atlas a practical execution system rather than a collection of architecture documents.

Atlas operations connect:

* Context
* Intelligence
* Production
* Validation
* State preservation

---

# 2. Operating Principle

Atlas follows this cycle:

```text
Understand

↓

Plan

↓

Execute

↓

Validate

↓

Record

↓

Improve
```

Every development action should preserve:

* Current context
* Execution result
* Evidence

---

# 3. Daily Operating Flow

```text
Start Day

↓

Load Atlas Context

↓

Check Project Status

↓

Sera Analysis

↓

Select Task

↓

Execute

↓

Validate

↓

Update Registry

↓

Commit

↓

End Day
```

---

# 4. Day Start Procedure

## Step 1 — Load Context

Review:

```text
README.md

↓

PROJECT_OVERVIEW.md

↓

PROJECT_STATUS.md

↓

ATLAS_STATE.json
```

Purpose:

Understand current system state.

---

## Step 2 — Check Environment

Confirm available capability.

Example:

```text
DEV_WORK

Available:
Blender
Python
Documentation


DEV_HOME_MAIN

Available:
Unreal
GPU AI
Rendering
```

---

## Step 3 — Review Active Projects

Current priority:

```text
Sera

↓

Forge

↓

Excelion
```

Check:

* Current goal
* Current sprint
* Blocking issues

---

# 5. Intelligence Phase

Sera is used for:

* Requirement analysis
* Architecture discussion
* Planning
* Problem solving

Sera output should become:

```text
Decision

↓

Task

↓

Execution Plan
```

Sera does not directly replace validation.

---

# 6. Execution Phase

Execution depends on capability.

## Company Environment

DEV_WORK:

Suitable for:

* Forge development
* Blender work
* Documentation
* Code development

---

## Home Main Environment

DEV_HOME_MAIN:

Suitable for:

* Unreal Engine
* AI execution
* Rendering
* Integration testing

---

## Secondary Environment

DEV_HOME_SUB:

Suitable for:

* Review
* Documentation
* Support tasks

---

# 7. Forge Operation Flow

Forge workflow:

```text
Requirement

↓

Asset / Tool Generation

↓

Blender / Unreal Integration

↓

Validation

↓

Evidence Recording
```

Every Forge task should record:

* Input
* Tool execution
* Result
* Validation status

---

# 8. State Update Procedure

After task completion:

1. Update task status.
2. Update project state.
3. Record evidence.
4. Commit changes.

State sources:

```text
ATLAS_STATE.json

+

Project Registry

+

Sprint Records
```

---

# 9. Database Usage

PostgreSQL may be used as a structured runtime store.

Possible data:

* Project state
* Task history
* Execution events
* Forge metadata

The database complements Git documents.

It does not replace version-controlled knowledge.

---

# 10. AI Integration Rules

Atlas supports:

## Local AI

Purpose:

* Fast interaction
* Private development
* Offline capability

## Cloud AI

Purpose:

* Large reasoning tasks
* Specialized models
* Additional capability

Rule:

AI output is assistance.

Final decisions require human validation.

---

# 11. Day End Procedure

Before finishing:

## Commit

Save:

* Code changes
* Documentation changes
* Configuration changes

---

## Update State

Update:

* Current task
* Progress
* Evidence

---

## Prepare Next Step

Generate:

* Next task
* Required environment
* Expected validation

---

# 12. Operating Rules

## Rule 1

Context must exist before execution.

## Rule 2

Execution results must be recorded.

## Rule 3

Environment capability must match task requirements.

## Rule 4

Documents describe decisions.

Code and assets represent execution.

## Rule 5

Automation grows from validated workflows.

---

# Summary

Atlas daily operation combines:

```text
Sera

↓

Planning


Atlas

↓

Coordination


Forge

↓

Production


Excelion

↓

Validation
```

The purpose of operations is to maintain a continuous development loop where knowledge, execution, and improvement are connected.
