# ADR-009: Environment Capability Model

## Status

Accepted

## Context

Atlas executes tasks across multiple development environments.

Different environments have different capabilities:

* Available software
* Hardware resources
* AI execution capability
* Network access
* External tool availability

A machine-based approach such as:

```text
Home PC
Company PC
```

is insufficient because execution requirements are based on capability, not location.

Atlas requires a capability-oriented environment model.

---

# Decision

Atlas defines environments by capability rather than physical machine identity.

Environment selection is based on whether the required capabilities are available.

The decision flow becomes:

```text id="5qg3b4"
Task Requirement

↓

Required Capability

↓

Environment Matching

↓

Execution Target
```

---

# Capability Definition

An environment may provide capabilities such as:

## Software Capability

Examples:

* Blender
* Unreal Engine
* VS Code
* Python
* Git

---

## Hardware Capability

Examples:

* GPU availability
* VRAM capacity
* CPU performance
* Storage availability

---

## AI Capability

Examples:

* Local LLM execution
* Cloud AI access
* Model availability

---

## Integration Capability

Examples:

* MCP support
* API access
* External service connectivity

---

# Environment Registry

Environment information is managed through the Environment Registry.

Example:

```yaml id="u7r2vz"
Environment:

  Name:
    DEV_HOME_MAIN

  Capabilities:

    Blender:
      true

    Unreal:
      true

    GPU:
      true

    Local_AI:
      true
```

---

# Resolver Responsibility

EnvironmentResolver evaluates available capabilities.

It provides:

* Available tools
* Hardware state
* Execution limitations

It does not:

* Choose tasks
* Override priority decisions

---

# Execution Example

Task:

```text id="4s0pna"
Unreal Animation Blueprint Test
```

Required Capability:

```text id="e5j7u1"
Unreal Engine

GPU

Project Access
```

Matching:

```text id="4p5yq6"
DEV_HOME_MAIN

✓ Unreal

✓ GPU

✓ Project Access
```

Execution proceeds on the matched environment.

---

# Forge Relationship

Forge workflows should define required capabilities.

Example:

```text id="0w4h8n"
Blender Rig Validation


Requirements:

Blender

Python

Asset Access
```

Atlas selects a compatible environment automatically.

---

# SERA Relationship

SERA may use environment information to:

* Recommend feasible tasks.
* Explain limitations.
* Suggest alternatives.

Example:

"Unreal validation cannot run here because Unreal capability is unavailable."

---

# Consequences

Positive:

* Environment selection becomes reliable.
* New machines can be added easily.
* Automation becomes portable.
* Hardware and software limitations become explicit.

Trade-offs:

* Capability definitions require maintenance.
* Environment discovery needs automation over time.
* More metadata is required.

---

# Summary

Atlas treats environments as capability providers rather than fixed machines.

This enables reliable execution across:

* Workstations
* Home systems
* Cloud environments
* Future build servers

The system chooses execution targets based on capability requirements, not location names.


---

# Related Decisions

Related:

- ADR-001 RuntimeContext as the Official Execution Model
- ADR-003 Registry Pattern for Shared Knowledge
- ADR-005 Plugin-Based Execution Architecture
- ADR-007 Forge as Production Framework