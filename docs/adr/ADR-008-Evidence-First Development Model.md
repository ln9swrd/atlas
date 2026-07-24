# ADR-008: Evidence-First Development Model

## Status

Accepted

## Context

AI-assisted development introduces a significant challenge:

AI systems can generate plausible but incorrect assumptions.

Atlas requires a development model that maintains reliability by ensuring that decisions and state changes are based on verifiable information.

Without an evidence-based approach:

* Project state may become inaccurate.
* AI recommendations may rely on outdated information.
* Execution results may be difficult to reproduce.
* Development history may be lost.

Atlas requires a method to connect decisions with observable evidence.

---

# Decision

Atlas adopts Evidence-First Development as a core operating principle.

All important decisions, executions, and state changes should be supported by evidence whenever possible.

The execution model becomes:

```text id="3ct4x2"
Context

↓

Evidence

↓

Decision

↓

Execution

↓

Validation

↓

Evidence Update

↓

State
```

---

# Evidence Definition

Evidence is any verifiable information that supports system understanding.

Examples:

## Development Evidence

* Source code changes
* Commit history
* Generated assets
* Build results

## Execution Evidence

* Logs
* Execution reports
* Test results
* Validation output

## Project Evidence

* Design documents
* Decisions
* Milestone completion records

---

# Evidence Relationship

Important system states should reference supporting evidence.

Example:

```text id="q9k3u4"
Task:

Forge Rig Validation


State:

Completed


Evidence:

Validation Report

+

Execution Log

+

Generated Asset
```

A completed state without supporting evidence should be considered incomplete.

---

# AI Operation Principle

AI systems operating within Atlas should:

* Prefer available evidence over assumptions.
* Identify missing information.
* Request validation when evidence is insufficient.

AI-generated suggestions are recommendations, not automatic truth.

---

# Validation Model

Execution results should pass validation before becoming trusted state.

Flow:

```text id="1n5b4p"
Execute

↓

Validate

↓

Record Evidence

↓

Update State
```

---

# Relationship with Atlas Components

## RuntimeContext

Provides the context in which evidence is evaluated.

## Registry

Stores references to known information and state.

## Decision Engine

Uses evidence as input for recommendations.

## Runner

Records execution results and evidence.

## SERA

Uses evidence to improve analysis and planning.

## Forge

Generates production evidence through validation workflows.

---

# Consequences

Positive:

* AI decisions become more reliable.
* Project state remains traceable.
* Debugging becomes easier.
* Development history is preserved.
* Automation can improve without losing control.

Trade-offs:

* Additional recording overhead is required.
* Evidence management becomes an important system responsibility.
* Some creative decisions cannot be fully measured.

---

# Summary

Evidence-First Development establishes trust as a foundation of Atlas.

Atlas does not treat generated information as truth until it is supported by:

* Context
* Verification
* Execution results
* Recorded evidence

This principle enables reliable AI-assisted development.


---

# Related Decisions

Related:

- ADR-001 RuntimeContext as the Official Execution Model
- ADR-003 Registry Pattern for Shared Knowledge
- ADR-005 Plugin-Based Execution Architecture
- ADR-006 State and Event Driven Execution Model
- ADR-007 Forge as Production Framework