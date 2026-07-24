# Environments

## 1. Purpose

This document defines the execution environments used by Atlas, Sera, and Forge.

Atlas does not assume that all tasks run in one machine.

Instead, environments are selected based on:

* Required capability
* Available resources
* Execution purpose

---

# 2. Environment Principle

Environment selection follows:

```text
Task Requirement

↓

Capability Detection

↓

Environment Selection

↓

Execution

↓

Validation
```

A machine is not the execution model.

Capability is the execution model.

---

# 3. Environment Registry

# DEV_WORK

## Role

Production Preparation Environment

## Purpose

Primary environment for:

* Blender production
* Python development
* Atlas development
* Sera development
* Documentation

## Capabilities

```text
✓ Blender

✓ Python

✓ VS Code

✓ Git

✓ Atlas

✓ Sera

✓ PostgreSQL Client
```

## Limitations

```text
✗ Unreal Engine

✗ High-end GPU AI execution
```

## Assigned Work

* Modeling
* Rigging
* Asset preparation
* Tool development
* Documentation
* Planning

---

# DEV_HOME_MAIN

## Role

High Capability Integration Environment

## Purpose

Primary environment for:

* Unreal development
* AI execution
* Final validation

## Capabilities

```text
✓ Blender

✓ Unreal Engine

✓ GPU AI Runtime

✓ VS Code

✓ Git

✓ Atlas

✓ Sera

✓ PostgreSQL Server

✓ Local Model Execution
```

## Assigned Work

* Unreal import
* Animation validation
* Rendering
* Packaging
* Gameplay testing
* AI-assisted development

---

# DEV_HOME_SUB

## Role

Secondary Support Environment

## Purpose

Support development and continuity.

## Capabilities

```text
✓ VS Code

✓ Git

✓ Sera

✓ Documentation

△ Blender

△ AI Runtime
```

## Assigned Work

* Code review
* Documentation
* Project management
* Lightweight tasks

---

# 4. Shared Infrastructure

## PostgreSQL

Purpose:

Central structured state storage.

Possible Usage:

* Atlas state
* Project registry
* Forge metadata
* Execution history

Model:

```text
Atlas

↓

PostgreSQL

↓

Project / Task / Evidence Data
```

---

## MCP Integration

Purpose:

Provide communication between AI agents and tools.

Possible Connections:

```text
Sera

↓

MCP

↓

Forge

↓

Blender / Unreal / Database
```

MCP acts as an integration layer, not a replacement for execution logic.

---

## Cloud AI

Purpose:

Extend local AI capability.

Usage:

* Large model inference
* Specialized reasoning
* Complex analysis
* External AI services

Principle:

Cloud AI supplements local capability.

The system must remain functional without depending on one provider.

---

# 5. Capability Matrix

| Capability        | DEV_WORK | DEV_HOME_MAIN | DEV_HOME_SUB |
| ----------------- | -------- | ------------- | ------------ |
| Atlas             | ✓        | ✓             | ✓            |
| Sera              | ✓        | ✓             | ✓            |
| Forge Development | ✓        | ✓             | △            |
| Blender           | ✓        | ✓             | △            |
| Unreal            | ✗        | ✓             | △            |
| GPU AI            | ✗        | ✓             | △            |
| PostgreSQL        | Client   | Server        | Client       |
| MCP               | ✓        | ✓             | △            |
| Git               | ✓        | ✓             | ✓            |

---

# 6. Forge Environment Rules

## Blender Workflow

Preferred:

```text
DEV_WORK
```

Tasks:

* Modeling
* Rigging
* Export preparation

---

## Unreal Workflow

Preferred:

```text
DEV_HOME_MAIN
```

Tasks:

* Import
* Blueprint
* Animation
* Packaging

---

## AI Intensive Workflow

Preferred:

```text
DEV_HOME_MAIN
+
Cloud AI
```

---

# 7. Environment Selection Rules

## Rule 1

Tasks must declare required capability.

## Rule 2

Execution results must record environment information.

## Rule 3

Production validation must occur in the appropriate environment.

## Rule 4

Environment limitations must be visible to Atlas.

---

# 8. Future Expansion

Possible future environments:

## Build Server

Purpose:

* Automated packaging
* CI execution

## Shared Production Database

Purpose:

* Multi-machine synchronization

## Cloud Execution Node

Purpose:

* Large-scale AI and rendering tasks

---

# Summary

Atlas manages development as a distributed capability environment.

```text
DEV_WORK

↓

Creation


DEV_HOME_MAIN

↓

Integration


DEV_HOME_SUB

↓

Support


Cloud

↓

Expansion
```

The goal is not to eliminate environment differences.

The goal is to use each environment correctly.
