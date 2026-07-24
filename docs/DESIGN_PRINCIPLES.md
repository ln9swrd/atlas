# Atlas Design Principles

This document defines the fundamental principles that guide the design and evolution of Atlas DevOS.

These principles apply to:

* Core architecture
* AI agents
* Execution workflows
* Production frameworks
* Project integrations

---

# 1. Context First

Atlas must understand the execution context before taking action.

The system should identify:

* Current project
* Current goal
* Current task
* Available environment
* Available tools
* Applicable rules

No execution should occur based only on incomplete assumptions.

---

# 2. RuntimeContext Is Immutable

RuntimeContext represents the execution situation at a specific moment.

Principle:

* RuntimeContext is created once for an execution cycle.
* Changes create a new context.
* Existing context history should remain traceable.

Purpose:

* Prevent hidden state changes.
* Preserve execution consistency.

---

# 3. Evidence First

Atlas decisions should be based on evidence whenever possible.

Evidence includes:

* Current state
* Documentation
* Test results
* Execution logs
* Validation results

Principle:

```text
Evidence

↓

Decision

↓

Execution
```

not:

```text
Assumption

↓

Execution
```

---

# 4. Resolvers Collect Context; They Do Not Decide

Resolvers are responsible only for collecting and normalizing information.

Examples:

* EnvironmentResolver
* ProjectResolver
* ResourceResolver
* TimeResolver

Resolvers must not:

* Select tasks
* Change priorities
* Execute actions

Decision responsibility belongs to:

* Rule Engine
* Priority Engine
* Agent reasoning layer

---

# 5. Engines Consume Context and Rules; They Do Not Own State

Decision engines evaluate information but do not become the source of truth.

Engines:

* Consume RuntimeContext
* Apply rules
* Produce recommendations

State ownership belongs to:

* Registry
* Runtime State
* Project Documents

---

# 6. Registries Are Source Data

Registries provide structured information.

Examples:

* Project Registry
* Environment Registry
* Goal Registry

Registries should:

* Store known information
* Provide consistent references

Registries should not:

* Execute actions
* Contain decision logic

---

# 7. The Runner Is an Orchestrator

The Runner coordinates execution.

Responsibilities:

* Execute approved workflows
* Call plugins
* Update execution state
* Record events

The Runner should not contain:

* Project-specific logic
* Creative decisions
* Business rules

---

# 8. Separation of Layers

Each layer must maintain clear responsibility boundaries.

Architecture:

```text
Core

↓

Agent

↓

Framework

↓

Project
```

Rules:

* Projects must not modify Core directly.
* Frameworks must not own project decisions.
* Agents must not replace system state management.

---

# 9. Human and AI Collaboration

Atlas is designed for human-AI collaboration.

AI responsibilities:

* Analysis
* Planning assistance
* Recommendation
* Information processing

Human responsibilities:

* Final decisions
* Creative direction
* Architecture approval
* Major changes

Automation should increase capability without removing necessary human control.

---

# 10. Extensible by Design

New capabilities should be added through appropriate extension points.

Examples:

* New AI agents
* New plugins
* New MCP integrations
* New project types

New features should be added to the lowest appropriate layer.

Example:

```text
Tool integration

→ Plugin Layer


Execution capability

→ Execution Layer


New reasoning capability

→ Agent Layer
```

---

# 11. Preserve Knowledge Continuity

Atlas must preserve development history.

Important information should remain available:

* Decisions
* Evidence
* State changes
* Execution records

The goal is continuous project understanding across development cycles.

---

# Summary

Atlas follows these core principles:

1. Context before action.
2. Evidence before assumption.
3. Separation of responsibility.
4. Controlled automation.
5. Human-AI collaboration.
6. Continuous knowledge preservation.

These principles allow Atlas to evolve as a reliable AI-assisted development operating system.
