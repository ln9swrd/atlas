# Forge Execution Contract

## 1. Purpose

This document defines the execution contract for Forge.

The purpose is to ensure that every production action has:

* Clear input
* Defined execution process
* Verifiable result
* Recorded evidence

Forge does not consider a task complete based only on intention or generated output.

---

# 2. Core Principle

Forge follows:

```text
Request

↓

Execution

↓

Validation

↓

Evidence

↓

Completion
```

A task cannot become completed without validation evidence.

---

# 3. Execution States

Every Forge task must have one of the following states.

## CREATED

Task exists but execution has not started.

---

## READY

Required context and resources are available.

---

## RUNNING

Execution is currently active.

---

## VALIDATING

Execution finished and result checking is in progress.

---

## COMPLETED

Validation succeeded and evidence exists.

---

## FAILED

Execution or validation failed.

---

## BLOCKED

Execution cannot continue due to missing requirements.

---

# 4. Required Execution Information

Before execution, Forge must know:

## Task Definition

Required:

* Task ID
* Objective
* Expected output

---

## Environment

Required:

* Execution machine
* Available tools
* Required dependencies

Example:

```text
DEV_WORK

Blender

Python

Git
```

or:

```text
DEV_HOME_MAIN

Unreal Engine

GPU

Build Environment
```

---

## Input Data

Required:

* Source files
* Parameters
* References

---

# 5. Execution Rules

## Rule 1 — No Evidence, No Completion

The following are not valid completion:

* "Generated successfully"
* "Should work"
* "Code was updated"

Valid completion requires:

* Output file
* Test result
* Validation log

---

## Rule 2 — Execution Must Be Observable

Each execution should record:

* Start time
* End time
* Tool used
* Result
* Error information

---

## Rule 3 — Validation Is Independent

The same process that creates a result should not be the only validator.

Example:

```text
Generator

↓

Validator
```

---

# 6. Asset Execution Contract

For 3D assets:

Required validation:

## File

* Exists
* Correct format

## Structure

* Naming rule
* Object hierarchy
* Material assignment

## Integration

* Import test
* Runtime check

Example:

```text
.blend

↓

FBX Export

↓

Unreal Import

↓

Validation PASS
```

---

# 7. AI Execution Contract

AI agents including Sera must follow:

## AI May:

* Analyze
* Suggest
* Generate instructions
* Modify approved files

## AI May Not:

* Claim unverified success
* Invent execution results
* Skip validation

---

# 8. Failure Handling

When execution fails:

Record:

* Error
* Environment
* Attempted action
* Recovery suggestion

Failure is also evidence.

---

# 9. Evidence Format

Example:

```json
{
  "task": "EX-BRAVE-006",
  "action": "Rig Validation",
  "status": "PASS",
  "evidence": [
    "rig_report.json",
    "validation_log.txt"
  ]
}
```

---

# 10. Integration With Atlas

Forge reports execution results to Atlas.

Flow:

```text
Forge

↓

Execution Event

↓

Atlas State

↓

Project Status
```

---

# 11. Design Goal

The purpose of this contract is:

```text
No assumption

No invisible execution

No false completion
```

Forge must always know:

* What was requested.
* What was executed.
* What was verified.
