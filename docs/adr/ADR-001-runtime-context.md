# ADR-001: RuntimeContext as the Official Execution Model

## Status

Accepted

---

## Context

Atlas requires a single stable representation of the current execution situation.

Without a unified execution model:

* Agents may interpret different states.
* Decision systems may use inconsistent information.
* Execution history becomes difficult to reproduce.

A common context model is required for:

* Planning
* Recommendation
* Execution
* Validation

---

## Decision

RuntimeContext is the official execution context model of Atlas.

RuntimeContext represents:

* Current project
* Current goal
* Current environment
* Current task
* Available capabilities
* Execution state

RuntimeContext is created through resolvers and consumed by decision and execution layers.

Architecture:

```text id="r9v2wf"
Registry

↓

Resolver

↓

RuntimeContext

↓

Decision

↓

Execution
```

---

## Principles

RuntimeContext must be:

* Explicit
* Traceable
* Reproducible
* Immutable during execution

---

## Consequences

Positive:

* All components share a consistent execution model.
* AI agents can understand current conditions.
* Execution results become easier to reproduce.

Future expansion:

Sera and Forge use RuntimeContext as the common foundation for:

* Planning
* Production workflows
* Validation

---

## Related Components

* Atlas Core
* Sera Intelligence Layer
* Forge Production Framework
