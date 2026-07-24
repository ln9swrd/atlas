# ADR-002: Layered Architecture for Atlas

## Status

Accepted

---

## Context

As Atlas expanded from a runtime framework into a complete AI development ecosystem, new capabilities needed a clear location.

Without architectural boundaries:

* Features could be added arbitrarily.
* Core logic could become coupled with project-specific behavior.
* Future systems such as Sera and Forge could introduce unnecessary dependencies.

A predictable structure was required to allow independent evolution.

---

## Decision

Atlas adopts a layered architecture.

The architecture is divided into:

```text
Layer 0

Core Domain


↓

Layer 1

Resolvers


↓

Layer 2

Decision


↓

Layer 3

Execution


↓

Layer 4

Interface
```

Each layer has a defined responsibility.

---

# Layer Responsibilities

## Layer 0 — Core Domain

Contains fundamental models:

* RuntimeContext
* State
* Event
* Goal
* Registry

The core layer must remain independent.

---

## Layer 1 — Resolvers

Responsible for collecting context.

Examples:

* EnvironmentResolver
* ProjectResolver
* ResourceResolver
* UserResolver

Resolvers do not make decisions.

---

## Layer 2 — Decision

Responsible for evaluation.

Examples:

* Priority Engine
* Rule Engine
* Recommendation Engine

Decision logic consumes context but does not own state.

---

## Layer 3 — Execution

Responsible for performing actions.

Examples:

* Runner
* Executor
* Scheduler
* PluginHost

Execution coordinates work but does not redefine business rules.

---

## Layer 4 — Interface

Provides external access.

Examples:

* CLI
* VS Code
* Web Interface
* API

---

## Dependency Direction

The dependency direction is:

```text
Registry

↓

Resolver

↓

RuntimeContext

↓

Decision

↓

Execution

↓

Interface
```

Upper layers may depend on lower layers.

Lower layers must not depend on upper layers.

---

## Consequences

Positive:

* New features have clear locations.
* Core stability is preserved.
* Components can evolve independently.
* AI agents and production frameworks can integrate safely.

Future support:

This architecture allows:

```text
Atlas Core

+

Sera Intelligence

+

Forge Production Framework

+

Future Projects
```

without changing the foundation layer.

---

## Related Decisions

* ADR-001: RuntimeContext Execution Model
* ADR-003: Registry Pattern for Shared Knowledge
* ADR-004: Rule-Based Priority Engine
