# ADR-003: Registry Pattern for Shared Knowledge

## Status

Accepted

---

## Context

Atlas requires a consistent method for managing shared information used across the system.

The platform contains multiple types of knowledge:

* Project information
* Goals
* Environment capability
* Runtime state
* Production metadata

Without a common access model:

* Components may create duplicate state.
* Agents may use inconsistent information.
* Execution results become difficult to reproduce.

---

## Decision

Atlas uses the Registry Pattern as the standard method for shared knowledge management.

Registries provide centralized, structured data sources.

Examples:

```text id="j6y8y7"
Project Registry

Goal Registry

Environment Registry

State Registry

Resource Registry
```

---

## Registry Principles

Registries are:

## Read-Oriented

Registries provide information to the system.

They are not decision makers.

---

## Structured

Data should have:

* Clear schema
* Ownership
* Validation rules

---

## Traceable

Changes must be observable through:

* Version control
* Events
* History records

---

# Registry Usage Model

The execution flow:

```text id="c9f9yq"
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

Resolvers consume registry information and construct execution context.

---

# Data Responsibility

## Atlas Registry

Manages:

* Project lifecycle
* Execution state
* Environment information

---

## Sera Context

Uses registry information for:

* Understanding project state
* Planning
* Analysis

---

## Forge Metadata

May use registries for:

* Asset information
* Production status
* Validation history

---

## PostgreSQL Extension

For runtime-scale data, registries may be backed by databases.

Example:

```text id="k2f4yw"
Git Documents

↓

Registry Definition


PostgreSQL

↓

Runtime Data
```

Database storage extends registry capability but does not replace documented knowledge.

---

## Consequences

Positive:

* Shared knowledge has a clear source.
* Components can access consistent information.
* Future expansion becomes easier.

Trade-offs:

* Registry schemas must be maintained.
* Data ownership must remain clear.

---

## Related Decisions

* ADR-001: RuntimeContext Execution Model
* ADR-002: Layered Architecture
* ADR-004: Rule-Based Priority Engine
