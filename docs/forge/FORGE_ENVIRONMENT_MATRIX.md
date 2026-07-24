# Forge Environment Matrix

## 1. Purpose

This document defines the execution environments used by Forge.

The purpose is to ensure that:

* Tasks are assigned to suitable environments.
* Required capabilities are known before execution.
* Production workflows remain reproducible.

Forge does not assume that every environment can execute every task.

---

# 2. Environment Principle

Forge uses capability-based execution.

The workflow is:

```text
Task Requirement

↓

Capability Check

↓

Environment Selection

↓

Execution

↓

Validation
```

Environment selection is based on available capability, not location alone.

---

# 3. Current Environment Registry

## DEV_WORK

Role:

Production Preparation Environment

Primary Usage:

* Blender production
* Python development
* Documentation
* Atlas development
* SERA development

Capabilities:

```text
✓ Blender

✓ Python

✓ VS Code

✓ Git

✓ Atlas

✓ SERA
```

Limitations:

```text
✗ Unreal Engine

✗ High-end GPU AI workload
```

Recommended Tasks:

* Modeling
* Rigging
* Asset preparation
* Script development
* Forge development
* Documentation

---

# DEV_HOME_MAIN

Role:

Integration and High Capability Environment

Primary Usage:

* Unreal development
* AI-assisted development
* Final validation

Capabilities:

```text
✓ Blender

✓ Unreal Engine

✓ GPU AI Models

✓ VS Code

✓ Git

✓ Atlas

✓ SERA

✓ Local AI Runtime
```

Recommended Tasks:

* Unreal import
* Animation validation
* Gameplay testing
* Rendering
* Packaging
* AI-assisted workflows

---

# DEV_HOME_SUB

Role:

Secondary Development Environment

Primary Usage:

* Lightweight development
* Review
* Documentation
* Support tasks

Capabilities:

```text
✓ VS Code

✓ Git

✓ SERA

✓ Documentation tools
```

Possible Capabilities:

```text
△ Blender

△ AI Runtime

△ Limited Processing
```

Limitations:

* Reduced performance
* Not primary production environment

---

# 4. Capability Matrix

| Capability    | DEV_WORK | DEV_HOME_MAIN | DEV_HOME_SUB |
| ------------- | -------- | ------------- | ------------ |
| Atlas         | ✓        | ✓             | ✓            |
| SERA          | ✓        | ✓             | ✓            |
| Blender       | ✓        | ✓             | △            |
| Unreal Engine | ✗        | ✓             | △            |
| GPU AI        | ✗        | ✓             | △            |
| Git           | ✓        | ✓             | ✓            |
| Documentation | ✓        | ✓             | ✓            |
| PostgreSQL    | △        | ✓             | △            |

---

# 5. Task Assignment Rules

## Blender Tasks

Preferred:

```text
DEV_WORK
```

Examples:

* Modeling
* Rigging
* Export preparation

---

## Unreal Tasks

Preferred:

```text
DEV_HOME_MAIN
```

Examples:

* Import
* Blueprint
* Animation
* Packaging

---

## AI Intensive Tasks

Preferred:

```text
DEV_HOME_MAIN
```

Examples:

* Local model execution
* Large code analysis
* Asset generation assistance

---

## Documentation Tasks

Allowed:

```text
DEV_WORK
DEV_HOME_MAIN
DEV_HOME_SUB
```

---

# 6. Forge Integration

Forge requests capability information from Atlas.

Example:

```text
Forge Task:

Validate Unreal Animation


Requirements:

Unreal Engine
Animation System
GPU


Result:

DEV_HOME_MAIN
```

---

# 7. Future Environment Expansion

Possible additions:

## Cloud AI Environment

Purpose:

* Large model execution
* Remote inference
* Specialized generation

## Build Server

Purpose:

* Automated packaging
* Continuous validation

## Shared Production Server

Purpose:

* Team collaboration
* Central asset database

---

# 8. Environment Rules

## Rule 1

A task must not execute without required capability.

## Rule 2

Environment changes must be recorded.

## Rule 3

Production results must include environment information.

## Rule 4

Local convenience must not override reproducibility.

---

# Summary

Forge uses multiple environments as a single production system.

The structure is:

```text
DEV_WORK

↓

Asset Creation


DEV_HOME_MAIN

↓

Integration / Validation


DEV_HOME_SUB

↓

Support / Review


Cloud

↓

Future Expansion
```

This environment model allows Atlas and Forge to select the correct execution location based on capability.
