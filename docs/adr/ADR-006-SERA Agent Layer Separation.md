# ADR-006: State and Event Driven Execution Model

## Status

Accepted

---

## Context

Atlas requires a reliable method to track execution progress, system changes, and validation results.

As runtime operations become more complex, direct state mutation between components creates risks:

* Hidden state changes
* Difficult debugging
* Loss of execution history
* Unclear responsibility boundaries

Atlas needs a consistent model for observing and recording changes.

---

## Decision

Atlas adopts a State and Event Driven Execution Model.

The system separates:

* Current state representation
* Historical event records

The relationship is:

```text
Action

↓

Event

↓

State Update

↓

RuntimeContext Refresh
```

---

## State Model

State represents the current known condition of the system.

Managed states include:

```text
System State

Project State

Task State

Execution State

Validation State
```

State must represent the latest confirmed condition.

---

## Event Model

Events represent meaningful changes that occurred during execution.

Examples:

```text
TASK_STARTED

TASK_COMPLETED

VALIDATION_PASSED

VALIDATION_FAILED

PLUGIN_EXECUTED

STATE_UPDATED
```

Events are append-only records.

---

## Decision Rules

1. State represents current truth.
2. Events represent historical evidence.
3. Components should not silently change state.
4. Important state transitions require event records.
5. RuntimeContext is rebuilt from validated state information.

---

## Consequences

### Positive

* Execution history becomes traceable.
* Debugging becomes easier.
* AI decision systems can reason from evidence.
* Failed operations can be analyzed.

### Negative

* Additional event management is required.
* State synchronization becomes more important.
* Storage growth must be managed.

---

## Relationship With Other Components

```text
Registry

↓

Resolver

↓

RuntimeContext

↓

Decision Engine

↓

Runner

↓

Event

↓

State Update
```

---

## Current Usage

Used by:

```text
Atlas Runtime

Sera Planning Context

Forge Execution Pipeline

Excelion Validation Workflow
```

---

## Summary

Atlas treats execution history as a first-class system resource.

The system does not only remember the current result.

It preserves how that result was produced.
