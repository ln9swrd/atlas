# ADR-005: Plugin-Based Execution Architecture

## Status

Accepted

---

## Context

Atlas execution runtime needs to support different types of actions without embedding every execution behavior directly into the core runner.

As Atlas expands into multiple workflows, including Sera intelligence tasks and Forge production pipelines, execution capabilities must remain modular.

A fixed execution implementation would create:

* Strong coupling between runtime and features
* Difficult extension of new capabilities
* Increased maintenance cost

---

## Decision

Atlas adopts a Plugin-Based Execution Architecture.

The execution layer is composed of:

```text
Execution Runtime

↓

Runner

↓

PluginHost

↓

Plugins
```

Plugins provide specialized capabilities while the runner remains responsible only for orchestration.

Initial plugin categories:

```text
RecommendationPlugin

ExecutionPlugin

ValidationPlugin

NotificationPlugin

LoggingPlugin
```

---

## Responsibilities

### Runner

The runner is responsible for:

* Receiving execution requests
* Managing execution flow
* Coordinating plugins
* Updating runtime state
* Emitting events

The runner must not contain domain-specific logic.

---

### PluginHost

PluginHost is responsible for:

* Plugin registration
* Plugin lifecycle management
* Plugin discovery
* Plugin execution routing

---

### Plugins

Plugins are responsible for:

* Specific execution behavior
* External tool interaction
* Specialized workflows

Examples:

```text
Forge Asset Plugin

Blender Validation Plugin

Unreal Integration Plugin

Sera Planning Plugin
```

---

## Consequences

### Positive

* Execution capabilities become replaceable.
* New features can be added without changing Runner.
* Multiple applications can share the same execution runtime.
* Plugin boundaries improve maintainability.

### Negative

* Plugin contracts must remain stable.
* Additional lifecycle management is required.
* Debugging requires execution trace visibility.

---

## Implementation Rules

1. Runner must remain an orchestrator.
2. Plugins must not directly modify unrelated system state.
3. Plugin communication must use defined contracts.
4. Execution results must produce evidence.
5. Plugin failures must be recorded as events.

---

## Related Decisions

Related:

* ADR-001 RuntimeContext
* ADR-002 Layered Architecture
* ADR-004 Priority Engine

---

## Current Usage

Current applications using this model:

```text
Atlas

↓

Sera

↓

Forge

↓

Excelion
```

Plugin execution allows Atlas to evolve from a project framework into a reusable development operating system.
