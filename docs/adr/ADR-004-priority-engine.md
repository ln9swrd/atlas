# ADR-004: Rule-Based Priority Engine

## Status

Accepted

---

## Context

Atlas requires a consistent method for selecting the next appropriate action.

As the system grows, priorities may depend on multiple factors:

* Project importance
* Current lifecycle stage
* Environment availability
* Dependencies
* Validation status
* Current goals

Embedding all decision logic directly into the engine would make the system difficult to maintain and extend.

---

## Decision

Atlas uses a Rule-Based Priority Engine.

The Priority Engine consumes external rules and evaluates available context.

The engine itself does not own business decisions.

---

# Decision Flow

```text id="z0f8dq"
Registry

↓

Resolver

↓

RuntimeContext

↓

Priority Rules

↓

Priority Engine

↓

Recommendation

↓

Execution
```

---

# Responsibilities

## Priority Rules

Responsible for defining decision criteria.

Examples:

* Project priority
* Task dependency
* Environment capability
* Current milestone
* Validation requirements

---

## Priority Engine

Responsible for:

* Evaluating context
* Applying rules
* Producing recommendations

The engine does not:

* Modify project state
* Execute tasks
* Store business data

---

# Integration With Atlas Ecosystem

## Sera

Sera can use Priority Engine results for:

* Planning discussion
* Task analysis
* Decision support

---

## Forge

Forge uses priority information for:

* Production workflow ordering
* Validation sequence
* Resource selection

---

## Excelion

Excelion provides real project data for validating priority decisions.

---

# Consequences

Positive:

* Decision logic can evolve independently.
* New strategies can be added through rules.
* Core execution remains stable.

Future expansion:

The system can support:

* More advanced scoring
* AI-assisted recommendations
* Multi-project optimization

---

# Design Principle

The Priority Engine should answer:

> "What should happen next?"

It should not answer:

> "How should everything work?"

Execution responsibility remains separated.

---

## Related Decisions

* ADR-001: RuntimeContext Execution Model
* ADR-002: Layered Architecture
* ADR-003: Registry Pattern for Shared Knowledge
